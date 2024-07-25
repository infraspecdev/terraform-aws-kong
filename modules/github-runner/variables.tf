variable "ami_id" {
  description = "AMI ID for the private instances"
  type        = string
  default     = "ami-0f58b397bc5c1f2e8"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet"
  type        = string
}

variable "key_name" {
  description = "The name of the EC2 key pair"
  type        = string
  default     = null
}

variable "github_org" {
  description = "The name of github organization"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "The name of github repository"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "Personal Access Token for github"
  type        = string
  sensitive   = true
}
