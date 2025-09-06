<!-- BEGIN_TF_DOCS -->
# terraform-aws-kong

Terraform Module to setup Kong(OSS) in ECS with self managed EC2 instances.

# Architectural Diagram

![Kong](https://github.com/infraspecdev/terraform-aws-kong/raw/main/diagrams/kong-architecture.png)

# Assumptions

This setup assumes that the `ECS cluster` that has `Auto Scaling Group (ASG)` exist with the name `default`. If you are using different name, you can provide those in the variables section of your Terraform configuration.

## Adding Parameters to AWS Systems Manager Parameter Store

Ensure you have the AWS CLI installed on your machine. You can find the installation instructions for different operating systems in the official AWS CLI documentation:
[Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Use the following commands to add the required parameters to AWS Systems Manager Parameter Store. These parameters are necessary for configuring your PostgreSQL database.

```sh
aws ssm put-parameter --name "/rds/POSTGRES_USERNAME" --value "value" --type "SecureString"
aws ssm put-parameter --name "/rds/POSTGRES_PASSWORD" --value "value" --type "SecureString"
aws ssm put-parameter --name "/rds/POSTGRES_DB_NAME" --value "value" --type "SecureString"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_kong"></a> [ecs\_kong](#module\_ecs\_kong) | infraspecdev/ecs-deployment/aws | ~> 4.3.4 |
| <a name="module_ecs_task_security_group"></a> [ecs\_task\_security\_group](#module\_ecs\_task\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.3.0 |
| <a name="module_internal_alb_kong"></a> [internal\_alb\_kong](#module\_internal\_alb\_kong) | infraspecdev/ecs-deployment/aws//modules/alb | ~> 4.3.4 |
| <a name="module_internal_alb_security_group"></a> [internal\_alb\_security\_group](#module\_internal\_alb\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.3.0 |
| <a name="module_kong_internal_dns_record"></a> [kong\_internal\_dns\_record](#module\_kong\_internal\_dns\_record) | ./modules/route-53-record | n/a |
| <a name="module_kong_public_dns_record"></a> [kong\_public\_dns\_record](#module\_kong\_public\_dns\_record) | ./modules/route-53-record | n/a |
| <a name="module_kong_rds"></a> [kong\_rds](#module\_kong\_rds) | terraform-aws-modules/rds/aws | ~> 6.12.0 |
| <a name="module_postgres_security_group"></a> [postgres\_security\_group](#module\_postgres\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.3.0 |
| <a name="module_public_alb_security_group"></a> [public\_alb\_security\_group](#module\_public\_alb\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The number of days to retain backups | `number` | `1` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster where Kong will be deployed | `string` | `"default"` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image for kong | `string` | `"kong:3.7.1-ubuntu"` | no |
| <a name="input_cpu_for_kong_task"></a> [cpu\_for\_kong\_task](#input\_cpu\_for\_kong\_task) | CPU required for kong task definiton | `number` | `256` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group for Kong RDS instance | `bool` | `true` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Initial allocated storage for Kong RDS instance in GBs | `number` | `20` | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | The maximum amount of allocated storage in GBs | `number` | `100` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection | `bool` | `false` | no |
| <a name="input_desired_count_for_kong_service"></a> [desired\_count\_for\_kong\_service](#input\_desired\_count\_for\_kong\_service) | Desired count for kong service | `number` | `1` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether to force new deployment | `bool` | `true` | no |
| <a name="input_kong_admin_domain_name"></a> [kong\_admin\_domain\_name](#input\_kong\_admin\_domain\_name) | Kong admin domain name | `string` | n/a | yes |
| <a name="input_kong_public_domain_name"></a> [kong\_public\_domain\_name](#input\_kong\_public\_domain\_name) | Kong public domain name | `string` | n/a | yes |
| <a name="input_log_configuration_for_kong"></a> [log\_configuration\_for\_kong](#input\_log\_configuration\_for\_kong) | Log configuration for kong | `any` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in.Syntax:ddd:hh24:mi-ddd:hh24:mi | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether to manage master user password | `bool` | `false` | no |
| <a name="input_memory_for_kong_task"></a> [memory\_for\_kong\_task](#input\_memory\_for\_kong\_task) | Memory required for kong task definiton | `number` | `256` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable performance insights | `bool` | `true` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | The retention period for performance insights | `number` | `7` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for database and Kong ECS deployment | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs for public-facing load balancers | `list(string)` | n/a | yes |
| <a name="input_rds_db_tags"></a> [rds\_db\_tags](#input\_rds\_db\_tags) | List of tags | `map(string)` | `{}` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | The RDS instance class for Kong database (e.g., db.t3.micro, db.r5.large) | `string` | `"db.t3.micro"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Name of the SSL Policy for the listener. | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where Kong infrastructure will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kong_ecs_service_arn"></a> [kong\_ecs\_service\_arn](#output\_kong\_ecs\_service\_arn) | ARN of Kong ECS service |
| <a name="output_kong_internal_alb_dns_name"></a> [kong\_internal\_alb\_dns\_name](#output\_kong\_internal\_alb\_dns\_name) | DNS name of Kong internal ALB |
| <a name="output_kong_public_alb_dns_name"></a> [kong\_public\_alb\_dns\_name](#output\_kong\_public\_alb\_dns\_name) | DNS name of Kong public ALB |
| <a name="output_kong_rds_instance_endpoint"></a> [kong\_rds\_instance\_endpoint](#output\_kong\_rds\_instance\_endpoint) | Endpoint of Kong RDS instance |
<!-- END_TF_DOCS -->
