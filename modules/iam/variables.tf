variable "name_prefix" {
  description = "Prefix for IAM role name"
  type        = string
}

variable "principal_type" {
  description = "Type of the principal (e.g., Service, User, etc.)"
  type        = string
}

variable "principal_identifiers" {
  description = "List of principal identifiers (e.g., ec2.amazonaws.com, ecs-tasks.amazonaws.com)"
  type        = list(string)
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}
