data "aws_acm_certificate" "base_domain_certificate" {
  domain      = var.base_domain
  statuses    = ["ISSUED"]
  most_recent = false
}

data "aws_route53_zone" "zone" {
  name = var.base_domain
}
