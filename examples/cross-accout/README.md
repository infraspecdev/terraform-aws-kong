<!-- BEGIN_TF_DOCS -->
# Cross-Account Example

This example demonstrates Kong deployment with **Route53 hosted zone in a different AWS account** using cross-account IAM role assumption.

## Use Case

Use this example when:
- Your Route53 hosted zone is managed in a separate AWS account (common in enterprise setups)
- You have a centralized DNS management account
- You need to manage DNS records across AWS accounts
- You follow security best practices with separate accounts for different concerns

## Key Features

- Cross-account Route53 DNS record management
- IAM role assumption for secure cross-account access
- Separate provider configuration for DNS operations
- Minimal configuration with module defaults for other resources
- Secure cross-account permissions model

## Provider Configuration

This example uses two providers:
1. **Default provider** - For Kong infrastructure (VPC, ECS, RDS, ALB)
2. **Cross-account provider** - For Route53 DNS records in a different account

```hcl
provider "aws" {
  alias  = "cross_account_provider"
  region = var.region
  assume_role {
    role_arn = var.route53_assume_role_arn  # IAM role in DNS account
  }
}
```

## Prerequisites

1. An IAM role must exist in the Route53 account that allows the Kong account to assume it
2. The role should have permissions to manage Route53 records
3. Example trust policy for the IAM role in the DNS account:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::KONG_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Usage

### Example Variable Values

Here is an example of how to define the variable values in your `terraform.tfvars` file:

```hcl
vpc_id                  = "vpc-12345678"
public_subnet_ids       = ["subnet-abcdef01", "subnet-abcdef02"]
private_subnet_ids      = ["subnet-abcdef03", "subnet-abcdef04"]
kong_public_domain_name = "api.example.com"
kong_admin_domain_name  = "admin-api.example.com"

# Cross-account Route53 IAM role (in the DNS account)
route53_assume_role_arn = "arn:aws:iam::DNS_ACCOUNT_ID:role/route53-cross-account-role"

region         = "ap-south-1"
cluster_name   = "default"
```

Place this `terraform.tfvars` file in the same directory as your Terraform configuration to automatically load these values. Adjust the values as needed to fit your specific environment and requirements.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kong"></a> [kong](#module\_kong) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kong_admin_domain_name"></a> [kong\_admin\_domain\_name](#input\_kong\_admin\_domain\_name) | The admin domain name for Kong | `string` | n/a | yes |
| <a name="input_kong_public_domain_name"></a> [kong\_public\_domain\_name](#input\_kong\_public\_domain\_name) | The public domain name for Kong | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
