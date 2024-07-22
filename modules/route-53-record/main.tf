resource "aws_route53_record" "record" {
  for_each = toset(var.endpoints)
  zone_id  = data.aws_route53_zone.zone.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

data "aws_acm_certificate" "base_domain_certificate" {
  domain      = var.base_domain
  statuses    = ["ISSUED"]
  most_recent = false
}

data "aws_route53_zone" "zone" {
  name = var.base_domain
}
