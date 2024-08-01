################################################################################
# Postgres Security Group
################################################################################

module "postgres_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name        = local.rds.sg_name
  description = "Allow all traffic within vpc"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
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

################################################################################
# RDS Kong
################################################################################

module "kong_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.7.0"

  identifier           = local.rds.db_identifier
  engine               = local.rds.engine
  engine_version       = local.rds.engine_version
  family               = local.rds.engine_family
  major_engine_version = local.rds.major_engine_version
  instance_class       = var.rds_instance_class

  storage_encrypted     = local.rds.storage_encrypted
  storage_type          = local.rds.storage_type
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.multi_az

  manage_master_user_password = var.manage_master_user_password
  db_name                     = local.rds.postgres_db_name
  username                    = local.rds.postgres_username
  port                        = local.rds.port
  password                    = local.rds.postgres_password

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

################################################################################
# Internal ALB Security Group
################################################################################

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

################################################################################
# Public ALB Security Group
################################################################################

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

################################################################################
# ECS Task Security Group
################################################################################

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
      cidr_blocks = data.aws_vpc.vpc.cidr_block
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

################################################################################
# ECS Execution IAM Role
################################################################################

module "ecs_exec_role" {
  source                = "./modules/iam"
  name_prefix           = local.ecs.iam.name_prefix
  principal_type        = local.ecs.iam.principal_type
  principal_identifiers = local.ecs.iam.principal_identifiers
  policy_arns           = local.ecs.iam.ecs_exec_policy_arn
}

################################################################################
# ECS Kong
################################################################################

module "ecs_kong" {
  source  = "infraspecdev/ecs-deployment/aws"
  version = "~> 2.0.0"

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
      security_groups  = [module.ecs_task_security_group.security_group_id]
      assign_public_ip = false
    }
  }
  task_definition = {
    family             = local.kong.task_definition_family
    network_mode       = local.kong.network_mode
    cpu                = var.cpu_for_kong_task
    memory             = var.memory_for_kong_task
    task_role_arn      = module.ecs_exec_role.role_arn
    execution_role_arn = module.ecs_exec_role.role_arn

    container_definitions = [
      {
        name         = local.kong.name
        image        = var.container_image
        essential    = true
        command      = local.kong.commands
        portMappings = local.kong.portMappings

        environment = [
          for key, value in local.kong.environment : {
            name  = key
            value = value
          }
        ]

        logConfiguration = var.log_configuration_for_kong
      }
    ]
  }

  capacity_provider_default_auto_scaling_group_arn = data.aws_autoscaling_group.this.arn
  capacity_providers = {
    kong = {
      name                           = local.kong.name
      managed_termination_protection = "DISABLED"
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

################################################################################
# Internal ALB Kong
################################################################################

module "internal_alb_kong" {
  source  = "infraspecdev/ecs-deployment/aws//modules/alb"
  version = "~> 2.0.0"

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

################################################################################
# Route53 Record For Public ALB
################################################################################

module "kong_public_dns_record" {
  source = "./modules/route-53-record"

  base_domain  = var.base_domain
  endpoints    = var.kong_public_sub_domain_names
  alb_dns_name = module.ecs_kong.alb_dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id
}

################################################################################
# Route53 Record For Internal ALB
################################################################################

module "kong_internal_dns_record" {
  source = "./modules/route-53-record"

  base_domain  = var.base_domain
  endpoints    = var.kong_admin_sub_domain_names
  alb_dns_name = module.internal_alb_kong.dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id
}

################################################################################
# Self-hosted Github Runner
################################################################################

module "github_runner" {
  source            = "./modules/github-runner"
  vpc_id            = var.vpc_id
  private_subnet_id = var.private_subnet_ids[0]
  github_org        = local.github.org
  github_repo       = local.github.repo
  github_token      = local.github.token
}
