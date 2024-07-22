data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

module "postgres_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name        = local.name
  description = "Allow all traffic within vpc"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 5432
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }, ]
  tags = local.default_tags
}

module "kong_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.7.0"

  identifier           = local.db_identifier
  engine               = local.rds_engine
  engine_version       = local.postgres.engine_version
  family               = local.postgres.engine_family
  major_engine_version = local.postgres.major_engine_version
  instance_class       = var.rds_instance_class

  storage_encrypted     = local.storage_encrypted
  storage_type          = local.storage_type
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.multi_az

  manage_master_user_password = var.manage_master_user_password
  db_name                     = var.db_name
  username                    = var.db_username
  port                        = local.postgres.port
  password                    = var.db_password

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  deletion_protection     = var.deletion_protection
  maintenance_window      = var.maintenance_window

  vpc_security_group_ids                = [module.postgres_security_group.security_group_id]
  create_db_subnet_group                = var.create_db_subnet_group
  subnet_ids                            = var.private_subnet_ids
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = merge(local.default_tags, var.rds_db_tags)
}

module "ecs_node_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name   = local.ecs.ecs_node_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }, ]
  tags = local.default_tags
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

module "internal_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name   = local.kong.alb_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = data.aws_vpc.vpc.cidr_block
  }]
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }, ]
  tags = local.default_tags
}

module "public_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name   = local.kong.alb_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    for port in [80, 443] :
    {
      protocol    = "tcp"
      from_port   = port
      to_port     = port
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }, ]
  tags = local.default_tags
}

module "ecs_task_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name   = local.kong.ecs_task_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }, ]
  tags = local.default_tags
}


module "ecs_kong" {
  source       = "../terraform-aws-ecs-deployment"
  vpc_id       = var.vpc_id
  cluster_name = var.cluster_name

  service = {
    name                 = local.kong.service_name
    desired_count        = var.desired_count_for_kong_service
    force_new_deployment = var.force_new_deployment
    load_balancer = [
      {
        target_group_arn = module.internal_alb_kong.target_groups_arns[local.kong.internal_target_group]
        container_name   = local.kong.name
        container_port   = local.kong.admin_port
      },
      {
        target_group   = local.kong.public_target_group
        container_name = local.kong.name
        container_port = local.kong.proxy_port
      }
    ]
    network_configuration = {
      subnets          = var.private_subnet_ids
      security_groups  = [var.use_default_ecs_task_security_group ? module.ecs_task_security_group.security_group_id : var.ecs_task_security_group_id]
      assign_public_ip = false
    }
  }
  task_definition = {
    family             = local.kong.task_definition_family
    network_mode       = local.kong.network_mode
    cpu                = var.cpu_for_kong_task
    memory             = var.memory_for_kong_task
    task_role_arn      = aws_iam_role.ecs_task_role.arn
    execution_role_arn = aws_iam_role.ecs_exec_role.arn

    container_definitions = [
      {
        name         = local.kong.name
        image        = var.container_image
        essential    = true
        command      = local.kong.commands
        portMappings = local.kong.portMappings

        environment = [
          for key, value in local.kong_parameters : {
            name  = key
            value = value
          }
        ]

        logConfiguration = var.log_configuration_for_kong
      }
    ]
  }

  autoscaling_group = {
    name                  = local.kong.name
    vpc_zone_identifier   = var.private_subnet_ids
    desired_capacity      = var.desired_capacity
    min_size              = var.min_size
    max_size              = var.max_size
    protect_from_scale_in = var.protect_from_scale_in
    launch_template = {
      name                   = local.kong.launch_template_name
      image_id               = local.kong.image_id
      instance_type          = var.instance_type_for_kong
      vpc_security_group_ids = [var.use_default_ecs_node_security_group ? module.ecs_node_security_group.security_group_id : var.ecs_node_security_group_id]
      key_name               = var.key_name_for_kong
      user_data              = local.ecs.user_data
    }

    iam_role_name               = local.kong.name
    iam_role_policy_attachments = local.kong.iam_role_policy_attachments
    iam_instance_profile_name   = local.kong.name

  }

  capacity_providers = {
    kong = {
      name = local.kong.name
      managed_scaling = {
        maximum_scaling_step_size = var.maximum_scaling_step_size
        minimum_scaling_step_size = var.minimum_scaling_step_size
        status                    = var.managed_scaling_status
        target_capacity           = var.target_capacity
      }
    }
  }
  default_capacity_providers_strategies = [
    {
      capacity_provider = local.kong.name
      base              = 0
      weight            = 1
    }
  ]

  load_balancer = {
    name                       = "${local.kong.name}-public"
    internal                   = false
    subnets_ids                = var.public_subnet_ids
    security_groups_ids        = [module.public_alb_security_group.security_group_id]
    enable_deletion_protection = false
    target_groups = {
      (local.kong.public_target_group) = {
        name        = "${local.kong.name}-public"
        port        = 8000
        protocol    = "HTTP"
        target_type = "ip"
        health_check = {
          enabled             = true
          path                = "/status"
          port                = local.kong.admin_port
          matcher             = 200
          interval            = 120
          timeout             = 5
          healthy_threshold   = 2
          unhealthy_threshold = 3
        }
      }
    }
    listeners = {
      kong_https = {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = module.kong_public_dns_record.certificate_arn
        ssl_policy      = var.ssl_policy

        default_action = [
          {
            type         = "forward"
            target_group = local.kong.public_target_group
            conditions = [
              {
                field  = "host-header"
                values = local.kong.public_domains
              }
            ]
          },
        ]
      }
    }
  }

  depends_on = [module.kong_rds]
}

module "internal_alb_kong" {
  source                     = "../terraform-aws-ecs-deployment//modules/alb"
  name                       = "${local.kong.name}-internal"
  internal                   = true
  subnets_ids                = var.private_subnet_ids
  security_groups_ids        = [module.internal_alb_security_group.security_group_id]
  enable_deletion_protection = false
  target_groups = {
    (local.kong.internal_target_group) = {
      name        = "${local.kong.name}-internal"
      port        = 8001
      protocol    = "HTTP"
      target_type = "ip"
      vpc_id      = var.vpc_id
      health_check = {
        enabled             = true
        path                = "/status"
        port                = local.kong.admin_port
        matcher             = 200
        interval            = 120
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
      }
    }
  }
  listeners = {
    kong_http = {
      port     = 80
      protocol = "HTTP"

      default_action = [
        {
          type         = "forward"
          target_group = local.kong.internal_target_group
          conditions = [
            {
              field  = "host-header"
              values = local.kong.admin_domains
            }
          ]
        },
      ]
    }
  }
}

module "kong_public_dns_record" {
  source = "./modules/route-53-record"

  base_domain  = var.base_domain
  endpoints    = var.kong_public_sub_domain_names
  alb_dns_name = module.ecs_kong.alb_dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id
}

module "kong_internal_dns_record" {
  source = "./modules/route-53-record"

  base_domain  = var.base_domain
  endpoints    = var.kong_admin_sub_domain_names
  alb_dns_name = module.internal_alb_kong.dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id
}
