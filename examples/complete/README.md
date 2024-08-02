<!-- BEGIN_TF_DOCS -->
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
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The number of days to retain backups | `number` | n/a | yes |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image for kong | `string` | n/a | yes |
| <a name="input_cpu_for_kong_task"></a> [cpu\_for\_kong\_task](#input\_cpu\_for\_kong\_task) | CPU required for kong task definiton | `number` | n/a | yes |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group | `bool` | n/a | yes |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | The maximum amount of allocated storage in GBs | `number` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection | `bool` | n/a | yes |
| <a name="input_desired_count_for_kong_service"></a> [desired\_count\_for\_kong\_service](#input\_desired\_count\_for\_kong\_service) | Desired count for kong service | `number` | n/a | yes |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether to force new deployment | `bool` | n/a | yes |
| <a name="input_kong_admin_domain_name"></a> [kong\_admin\_domain\_name](#input\_kong\_admin\_domain\_name) | The admin domain name for Kong | `string` | n/a | yes |
| <a name="input_kong_public_domain_name"></a> [kong\_public\_domain\_name](#input\_kong\_public\_domain\_name) | The public domain name for Kong | `string` | n/a | yes |
| <a name="input_log_configuration_for_kong"></a> [log\_configuration\_for\_kong](#input\_log\_configuration\_for\_kong) | Log configuration for kong | `any` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in.Syntax:ddd:hh24:mi-ddd:hh24:mi | `string` | n/a | yes |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether to manage master user password | `bool` | n/a | yes |
| <a name="input_memory_for_kong_task"></a> [memory\_for\_kong\_task](#input\_memory\_for\_kong\_task) | Memory required for kong task definiton | `number` | n/a | yes |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ | `bool` | n/a | yes |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable performance insights | `bool` | n/a | yes |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | The retention period for performance insights | `number` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs | `list(string)` | n/a | yes |
| <a name="input_rds_db_tags"></a> [rds\_db\_tags](#input\_rds\_db\_tags) | List of tags | `map(string)` | n/a | yes |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | The instance class to use | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) Name of the SSL Policy for the listener. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
