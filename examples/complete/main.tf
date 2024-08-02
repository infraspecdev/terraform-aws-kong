module "kong" {
  source = "../../"

  vpc_id                  = var.vpc_id
  public_subnet_ids       = var.public_subnet_ids
  private_subnet_ids      = var.private_subnet_ids
  kong_public_domain_name = var.kong_public_domain_name
  kong_admin_domain_name  = var.kong_admin_domain_name

  rds_instance_class                    = var.rds_instance_class
  db_max_allocated_storage              = var.db_max_allocated_storage
  manage_master_user_password           = var.manage_master_user_password
  backup_retention_period               = var.backup_retention_period
  deletion_protection                   = var.deletion_protection
  create_db_subnet_group                = var.create_db_subnet_group
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  rds_db_tags                           = var.rds_db_tags
  multi_az                              = var.multi_az
  backup_window                         = var.backup_window
  maintenance_window                    = var.maintenance_window

  ssl_policy                     = var.ssl_policy
  container_image                = var.container_image
  log_configuration_for_kong     = var.log_configuration_for_kong
  cpu_for_kong_task              = var.cpu_for_kong_task
  memory_for_kong_task           = var.memory_for_kong_task
  desired_count_for_kong_service = var.desired_count_for_kong_service
  force_new_deployment           = var.force_new_deployment
}
