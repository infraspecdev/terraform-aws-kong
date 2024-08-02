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
