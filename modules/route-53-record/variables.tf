variable "base_domain" {
  description = "The base domain for the Route 53 zone"
  type        = string
}

variable "endpoints" {
  description = "A list of endpoints for which to create Route 53 records"
  type        = list(string)
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB zone ID"
  type        = string
}
