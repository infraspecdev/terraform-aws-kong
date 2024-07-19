variable "private_subnet_ids" {
  description = "List of private subnet id"
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

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "kong"
}

variable "db_username" {
  description = "Username for database"
  type        = string
  default     = "kong"
}

variable "db_password" {
  description = "Username for database"
  type        = string
  default     = "defaultpassword"
}

variable "rds_db_tags" {
  description = "List of tags"
  type        = map(string)
  default     = {}
}

variable "postgres_sg_tags" {
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

variable "region" {
  description = "AWS region"
  type        = string
}
