locals {
  domain_parts = regexall("(.*\\.)?(.*\\..*)", var.domain)
  base_domain  = length(local.domain_parts) > 0 && length(local.domain_parts[0]) > 1 ? local.domain_parts[0][1] : var.domain
}

data "aws_acm_certificate" "domain" {
  domain      = local.base_domain
  statuses    = ["ISSUED"]
  most_recent = false
}

data "aws_route53_zone" "zone" {
  name = local.base_domain
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
