variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "kong_public_domain_name" {
  description = "The public domain name for Kong"
  type        = string
}

variable "kong_admin_domain_name" {
  description = "The admin domain name for Kong"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class to use"
  type        = string
}

variable "db_max_allocated_storage" {
  description = "The maximum amount of allocated storage in GBs"
  type        = number
}

variable "manage_master_user_password" {
  description = "Whether to manage master user password"
  type        = bool
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group"
  type        = bool
}

variable "performance_insights_enabled" {
  description = "Whether to enable performance insights"
  type        = bool
}

variable "performance_insights_retention_period" {
  description = "The retention period for performance insights"
  type        = number
}

variable "rds_db_tags" {
  description = "List of tags"
  type        = map(string)
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  type        = string
}

variable "maintenance_window" {
  description = "The window to perform maintenance in.Syntax:ddd:hh24:mi-ddd:hh24:mi"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "ssl_policy" {
  type        = string
  description = "(Optional) Name of the SSL Policy for the listener."
}

variable "container_image" {
  description = "Container image for kong"
  type        = string
}

variable "log_configuration_for_kong" {
  description = "Log configuration for kong"
  type        = any
}

variable "cpu_for_kong_task" {
  description = "CPU required for kong task definiton"
  type        = number
}

variable "memory_for_kong_task" {
  description = "Memory required for kong task definiton"
  type        = number
}

variable "desired_count_for_kong_service" {
  description = "Desired count for kong service"
  type        = number
}

variable "force_new_deployment" {
  description = "Whether to force new deployment"
  type        = bool
}

variable "postgres_engine_version" {
  description = "The version of the Postgres engine"
  type        = number
}

variable "postgres_major_engine_version" {
  description = "The major version of the Postgres engine"
  type        = number
}

variable "route53_assume_role_arn" {
  description = "IAM role ARN for cross-account Route53 access."
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}
variable "s3_bucket_force_destroy" {
  description = "Whether to force destroy the S3 bucket used for Kong logs"
  type        = bool
}
