locals {
  kong_container_image = "kong:3.7.1-ubuntu"
  name                 = "kong-postgres"
  db_identifier        = "${local.name}-01"
  rds_engine           = "postgres"
  storage_encrypted    = true
  storage_type         = "gp3"

  postgres = {
    engine_version       = 16.3
    engine_family        = "postgres16"
    major_engine_version = 16
    port                 = 5432
  }

  default_tags = {
    ManagedBy = "Terraform"
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}


module "postgres-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  name        = local.name
  description = "Allow all traffic within vpc"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
  ]

  tags = merge(local.default_tags, var.postgres_sg_tags)
}

module "kong-rds" {
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

  vpc_security_group_ids                = [module.postgres-security-group.security_group_id]
  create_db_subnet_group                = var.create_db_subnet_group
  subnet_ids                            = var.private_subnet_ids
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = merge(local.default_tags, var.rds_db_tags)
}

