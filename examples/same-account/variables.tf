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

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
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
  description = "The ARN of the DNS role"
  type        = string
  default     = null
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "s3_bucket_force_destroy" {
  description = "Whether to force destroy the S3 bucket used for Kong logs"
  type        = bool
}
