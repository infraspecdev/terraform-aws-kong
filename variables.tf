variable "private_subnet_ids" {
  description = "List of private subnet id"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet id"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The amount of allocated storage in GBs"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "The maximum amount of allocated storage in GBs"
  type        = number
  default     = 100
}

variable "manage_master_user_password" {
  description = "Whether to manage master user password"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 1
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = "default"
}

variable "asg_name" {
  description = "Name of the auto scaling group"
  type        = string
  default     = "default"
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Whether to enable performance insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "The retention period for performance insights"
  type        = number
  default     = 7
}

variable "rds_db_tags" {
  description = "List of tags"
  type        = map(string)
  default     = {}
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "The window to perform maintenance in.Syntax:ddd:hh24:mi-ddd:hh24:mi"
  type        = string
  default     = null
}

variable "ssl_policy" {
  type        = string
  description = "(Optional) Name of the SSL Policy for the listener."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "kong_public_domain_name" {
  description = "Kong public domain name"
  type        = string
}

variable "kong_admin_domain_name" {
  description = "Kong admin domain name"
  type        = string
}

variable "maximum_scaling_step_size" {
  description = "Maximum scaling step size"
  type        = number
  default     = 2
}

variable "minimum_scaling_step_size" {
  description = "Minimum scaling step size"
  type        = number
  default     = 1
}

variable "managed_scaling_status" {
  description = "Mangaed scaling"
  type        = string
  default     = "ENABLED"
}

variable "target_capacity" {
  description = "Target Capacity for managed scaling"
  type        = number
  default     = 100
}

variable "container_image" {
  description = "Container image for kong"
  type        = string
  default     = "kong:3.7.1-ubuntu"
}

variable "log_configuration_for_kong" {
  description = "Log configuration for kong"
  type        = any
  default     = null
}

variable "cpu_for_kong_task" {
  description = "CPU required for kong task definiton"
  type        = number
  default     = 256
}

variable "memory_for_kong_task" {
  description = "Memory required for kong task definiton"
  type        = number
  default     = 256
}

variable "desired_count_for_kong_service" {
  description = "Desired count for kong service"
  type        = number
  default     = 1
}

variable "force_new_deployment" {
  description = "Whether to force new deployment"
  type        = bool
  default     = true
}
