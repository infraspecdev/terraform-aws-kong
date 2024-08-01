output "certificate_arn" {
  description = "ARN of the base domain certificate"
  value       = data.aws_acm_certificate.domain.arn
}

output "zone_id" {
  description = "ID of the Route 53 zone"
  value       = data.aws_route53_zone.zone.zone_id
}
