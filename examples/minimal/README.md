<!-- BEGIN_TF_DOCS -->
### Example Variable Values

Here is an example of how to define the variable values in your `terraform.tfvars` file:

```hcl
vpc_id                  = "vpc-12345678"
public_subnet_ids       = ["subnet-abcdef01", "subnet-abcdef02"]
private_subnet_ids      = ["subnet-abcdef03", "subnet-abcdef04"]
kong_public_domain_name = "api.example.com"
kong_admin_domain_name  = "admin-api.example.com"
```

Place this `terraform.tfvars` file in the same directory as your Terraform configuration to automatically load these values. Adjust the values as needed to fit your specific environment and requirements.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.4 |

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
