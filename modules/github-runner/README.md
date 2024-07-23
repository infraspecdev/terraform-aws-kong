## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for the private instances | `string` | `"ami-0f58b397bc5c1f2e8"` | no |
| <a name="input_github_config_token"></a> [github\_config\_token](#input\_github\_config\_token) | Github config token for self-hosted runners | `string` | n/a | yes |
| <a name="input_github_config_url"></a> [github\_config\_url](#input\_github\_config\_url) | Github config url for self-hosted runners | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the EC2 key pair | `string` | `"runner"` | no |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | The ID of the private subnet | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

No outputs.
