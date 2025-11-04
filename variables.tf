variable "private_subnet_ids" {
  description = "List of private subnet IDs for database and Kong ECS deployment"
  type        = list(string)
  nullable    = false
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for public-facing load balancers"
  type        = list(string)
  nullable    = false
}

variable "vpc_id" {
  description = "The ID of the VPC where Kong infrastructure will be deployed"
  type        = string
  nullable    = false
}

variable "rds_instance_class" {
  description = "The RDS instance class for Kong database (e.g., db.t3.micro, db.r5.large)"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.rds_instance_class))
    error_message = "RDS instance class must start with 'db.' (e.g., db.t3.micro, db.r5.large)."
  }
}

variable "db_allocated_storage" {
  description = "Initial allocated storage for Kong RDS instance in GBs"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GBs for RDS instances."
  }
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

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = false
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group for Kong RDS instance"
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

variable "cluster_name" {
  description = "Name of the ECS cluster where Kong will be deployed"
  type        = string
  default     = "default"
}

variable "ssl_policy" {
  type        = string
  description = "Name of the SSL Policy for the listener."
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

variable "postgres_engine_version" {
  description = "PostgreSQL engine version for the RDS instance (e.g., 15.4, 16.3). Defaults to latest supported."
  type        = number
  default     = 16.3
  validation {
    condition     = var.postgres_engine_version >= 16
    error_message = "The PostgreSQL engine version must be 16 or higher."
  }
}

variable "postgres_major_engine_version" {
  description = "Major PostgreSQL engine version (e.g., 15, 16). Used for parameter group family naming."
  type        = number
  default     = 16
  validation {
    condition     = var.postgres_major_engine_version >= 16
    error_message = "The major PostgreSQL engine version must be 16 or higher."
  }
}
