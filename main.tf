data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_ssm_parameter" "rds" {
  for_each        = toset(local.ssm_parameters.rds)
  name            = "/rds/${each.value}"
  with_decryption = true
}

################################################################################
# Postgres Security Group
################################################################################

module "postgres_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.0"

  name        = local.rds.sg_name
  description = local.rds.sg_description
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = local.rds.port
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.this.cidr_block
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
  version = "~> 6.13.0"

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
  version = "~> 5.3.0"

  name   = local.kong.alb_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = data.aws_vpc.this.cidr_block
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
  version = "~> 5.3.0"

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
  version = "~> 5.3.0"

  name   = local.kong.ecs_task_sg_name
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = data.aws_vpc.this.cidr_block
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

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = local.ecs.iam.principal_type
      identifiers = local.ecs.iam.principal_identifiers
    }
  }
}

resource "aws_iam_role" "ecs_exec" {
  name_prefix        = local.ecs.iam.name_prefix
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  count      = length(local.ecs.iam.ecs_exec_policy_arn)
  role       = aws_iam_role.ecs_exec.name
  policy_arn = element(local.ecs.iam.ecs_exec_policy_arn, count.index)
}

################################################################################
# ECS Kong
################################################################################

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

module "ecs_kong" {
  source  = "infraspecdev/ecs-deployment/aws"
  version = "~> 5.0.0"

  vpc_id       = var.vpc_id
  cluster_name = data.aws_ecs_cluster.this.cluster_name

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
    task_role_arn      = aws_iam_role.ecs_exec.arn
    execution_role_arn = aws_iam_role.ecs_exec.arn

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
    volume = []
  }

  create_capacity_provider = false

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
        port        = 443
        protocol    = "HTTPS"
        certificate = local.kong.public_acm_certificate
        ssl_policy  = var.ssl_policy

        default_action = [
          {
            type         = "forward"
            target_group = local.kong.public_target_group
            conditions = [
              {
                field  = "host-header"
                values = var.kong_public_domain_name
              }
            ]
          },
        ]
      }
    }
  }

  create_acm = true

  providers = {
    aws                        = aws
    aws.cross_account_provider = aws.cross_account_provider
  }
  acm_certificates = {
    (local.kong.public_acm_certificate) = {
      domain_name = var.kong_public_domain_name
      validation_option = {
        domain_name       = var.kong_public_domain_name
        validation_domain = var.kong_public_domain_name
      }

      record_zone_id = (
        var.route53_assume_role_arn != null
        ? module.kong_public_dns_record[0].zone_id
        : module.kong_public_dns_record_same_account[0].zone_id
      )
    }
  }

  route53_assume_role_arn = var.route53_assume_role_arn

  depends_on = [module.kong_rds]
}

################################################################################
# Internal ALB Kong
################################################################################

module "internal_alb_kong" {
  source  = "infraspecdev/ecs-deployment/aws//modules/alb"
  version = "~> 5.0.0"

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
              values = var.kong_admin_domain_name
            }
          ]
        },
      ]
    }
  }

  tags = local.default_tags
}

################################################################################
# Route53 Record For Public ALB
################################################################################
module "kong_public_dns_record_same_account" {
  count  = var.route53_assume_role_arn == null ? 1 : 0
  source = "./modules/route-53-record"

  domain       = var.kong_public_domain_name
  alb_dns_name = module.ecs_kong.alb_dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id

  providers = {
    aws = aws
  }
}

################################################################################
# Route53 Record For Internal ALB
################################################################################
module "kong_internal_dns_record_same_account" {
  count  = var.route53_assume_role_arn == null ? 1 : 0
  source = "./modules/route-53-record"

  domain       = var.kong_admin_domain_name
  alb_dns_name = module.internal_alb_kong.dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id

  providers = {
    aws = aws
  }
}

module "kong_public_dns_record" {
  count  = var.route53_assume_role_arn != null ? 1 : 0
  source = "./modules/route-53-record"

  domain       = var.kong_public_domain_name
  alb_dns_name = module.ecs_kong.alb_dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id

  providers = {
    aws = aws.cross_account_provider
  }
}

module "kong_internal_dns_record" {
  count  = var.route53_assume_role_arn != null ? 1 : 0
  source = "./modules/route-53-record"

  domain       = var.kong_admin_domain_name
  alb_dns_name = module.internal_alb_kong.dns_name
  alb_zone_id  = module.ecs_kong.alb_zone_id

  providers = {
    aws = aws.cross_account_provider
  }
}
