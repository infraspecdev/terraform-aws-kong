<!-- BEGIN_TF_DOCS -->
# AWS Route53 Setup for Domain

This Terraform module sets up an AWS Route53 record for a given domain and retrieves the most recent AWS ACM certificate for the base domain. It uses an existing Application Load Balancer (ALB) to create an alias record in Route53.

## Assumptions

- You have a domain managed by AWS Route53.
- You have an existing ALB with a DNS name and zone ID.
- The ACM certificate for your domain is already issued and available in your AWS account.

## Prerequisites

1. **Terraform:** Make sure you have Terraform installed. Refer to the [Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) if needed.
2. **AWS Credentials:** Ensure your AWS credentials are configured. You can do this by setting environment variables or using the AWS credentials file.
3. **Existing Resources:** The following resources must already exist:
   - An AWS Route53 hosted zone for your domain.
   - An AWS ACM certificate for your domain that is in the `ISSUED` state.
   - An ALB with a DNS name and zone ID.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_acm_certificate.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_dns_name"></a> [alb\_dns\_name](#input\_alb\_dns\_name) | ALB DNS name | `string` | n/a | yes |
| <a name="input_alb_zone_id"></a> [alb\_zone\_id](#input\_alb\_zone\_id) | ALB zone ID | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ARN of the base domain certificate |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | ID of the Route 53 zone |
<!-- END_TF_DOCS -->
