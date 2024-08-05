output "rds_instance_endpoint" {
  description = "Endpoint of RDS instance"
  value       = module.kong_rds.db_instance_endpoint
}

output "ecs_service_arn" {
  description = "ARN of kong ECS service"
  value       = module.ecs_kong.ecs_service_arn
}

output "public_alb_dns" {
  description = "DNS name of public ALB"
  value       = module.ecs_kong.alb_dns_name
}

output "internal_alb_dns" {
  description = "DNS name of internal ALB"
  value       = module.internal_alb_kong.arn
}
