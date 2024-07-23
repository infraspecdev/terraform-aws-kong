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
  default     = "runner"
}

variable "github_config_url" {
  description = "Github config url for self-hosted runners"
  type        = string
  sensitive   = true
}

variable "github_config_token" {
  description = "Github config token for self-hosted runners"
  type        = string
  sensitive   = true
}
