output "kong_rds_instance_endpoint" {
  description = "Endpoint of Kong RDS instance"
  value       = module.kong_rds.db_instance_endpoint
}

output "kong_ecs_service_arn" {
  description = "ARN of Kong ECS service"
  value       = module.ecs_kong.ecs_service_arn
}

output "kong_public_alb_dns_name" {
  description = "DNS name of Kong public ALB"
  value       = module.ecs_kong.alb_dns_name
}

output "kong_internal_alb_dns_name" {
  description = "DNS name of Kong internal ALB"
  value       = module.internal_alb_kong.arn
}
