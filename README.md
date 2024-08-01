# Architectural Diagram

![Kong](https://github.com/user-attachments/assets/3dda9db7-cf8e-4cd2-a507-4e50f9252ffe)

# Prerequisites for Setting Up AWS SSM Parameters

To configure and manage your AWS resources and GitHub Actions using Secure String parameters in AWS Systems Manager Parameter Store, follow the steps below to add the required parameters:

# Important Note

This setup assumes that the ECS cluster and Auto Scaling Group (ASG) exist with the name default. If you are using different names, you can provide those in the variables section of your Terraform configuration.

## AWS CLI Installation

Ensure you have the AWS CLI installed on your machine. You can install the AWS CLI using the following commands based on your operating system:

### Windows
```sh
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

### macOS
```sh
brew install awscli
```

### Linux
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## AWS CLI Configuration

Configure the AWS CLI with your AWS credentials and region. Run the following command and follow the prompts to enter your AWS Access Key, Secret Access Key, and default region:

```sh
aws configure
```

## Adding Parameters to AWS Systems Manager Parameter Store

Use the following commands to add the required parameters to AWS Systems Manager Parameter Store. These parameters are necessary for configuring your PostgreSQL database and GitHub Actions.

### RDS Parameters

```sh
aws ssm put-parameter --name "/rds/POSTGRES_USERNAME" --value "value" --type "SecureString"
aws ssm put-parameter --name "/rds/POSTGRES_PASSWORD" --value "value" --type "SecureString"
aws ssm put-parameter --name "/rds/POSTGRES_DB_NAME" --value "value" --type "SecureString"
```

### GitHub Parameters

```sh
aws ssm put-parameter --name "/github-action/GITHUB_ORG" --value "value" --type "SecureString"
aws ssm put-parameter --name "/github-action/GITHUB_REPO" --value "value" --type "SecureString"
aws ssm put-parameter --name "/github-action/GITHUB_TOKEN" --value "value" --type "SecureString"
```

## Verifying Parameter Storage

After adding the parameters, you can verify their storage in AWS Systems Manager Parameter Store using the following command:

```sh
aws ssm get-parameters --names "/rds/POSTGRES_USERNAME" "/rds/POSTGRES_PASSWORD" "/rds/POSTGRES_DB_NAME" "/github-action/GITHUB_ORG" "/github-action/GITHUB_REPO" "/github-action/GITHUB_TOKEN" --with-decryption
```

This command will display the values of the stored parameters, ensuring they have been added correctly.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.59.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_exec_role"></a> [ecs\_exec\_role](#module\_ecs\_exec\_role) | ./modules/iam | n/a |
| <a name="module_ecs_kong"></a> [ecs\_kong](#module\_ecs\_kong) | infraspecdev/ecs-deployment/aws | ~> 2.0.0 |
| <a name="module_ecs_task_security_group"></a> [ecs\_task\_security\_group](#module\_ecs\_task\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.1.2 |
| <a name="module_github_runner"></a> [github\_runner](#module\_github\_runner) | ./modules/github-runner | n/a |
| <a name="module_internal_alb_kong"></a> [internal\_alb\_kong](#module\_internal\_alb\_kong) | infraspecdev/ecs-deployment/aws//modules/alb | ~> 2.0.0 |
| <a name="module_internal_alb_security_group"></a> [internal\_alb\_security\_group](#module\_internal\_alb\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.1.2 |
| <a name="module_kong_internal_dns_record"></a> [kong\_internal\_dns\_record](#module\_kong\_internal\_dns\_record) | ./modules/route-53-record | n/a |
| <a name="module_kong_public_dns_record"></a> [kong\_public\_dns\_record](#module\_kong\_public\_dns\_record) | ./modules/route-53-record | n/a |
| <a name="module_kong_rds"></a> [kong\_rds](#module\_kong\_rds) | terraform-aws-modules/rds/aws | ~> 6.7.0 |
| <a name="module_postgres_security_group"></a> [postgres\_security\_group](#module\_postgres\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.1.2 |
| <a name="module_public_alb_security_group"></a> [public\_alb\_security\_group](#module\_public\_alb\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_ssm_parameter.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | Name of the auto scaling group | `string` | `"default"` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The number of days to retain backups | `number` | `1` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | `"default"` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image for kong | `string` | `"kong:3.7.1-ubuntu"` | no |
| <a name="input_cpu_for_kong_task"></a> [cpu\_for\_kong\_task](#input\_cpu\_for\_kong\_task) | CPU required for kong task definiton | `number` | `256` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | Whether to create a DB subnet group | `bool` | `true` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | The amount of allocated storage in GBs | `number` | `20` | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | The maximum amount of allocated storage in GBs | `number` | `100` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection | `bool` | `false` | no |
| <a name="input_desired_count_for_kong_service"></a> [desired\_count\_for\_kong\_service](#input\_desired\_count\_for\_kong\_service) | Desired count for kong service | `number` | `1` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether to force new deployment | `bool` | `true` | no |
| <a name="input_kong_admin_domain_name"></a> [kong\_admin\_domain\_name](#input\_kong\_admin\_domain\_name) | Kong admin domain name | `string` | n/a | yes |
| <a name="input_kong_public_domain_name"></a> [kong\_public\_domain\_name](#input\_kong\_public\_domain\_name) | Kong public domain name | `string` | n/a | yes |
| <a name="input_log_configuration_for_kong"></a> [log\_configuration\_for\_kong](#input\_log\_configuration\_for\_kong) | Log configuration for kong | `any` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in.Syntax:ddd:hh24:mi-ddd:hh24:mi | `string` | `null` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether to manage master user password | `bool` | `false` | no |
| <a name="input_managed_scaling_status"></a> [managed\_scaling\_status](#input\_managed\_scaling\_status) | Mangaed scaling | `string` | `"ENABLED"` | no |
| <a name="input_maximum_scaling_step_size"></a> [maximum\_scaling\_step\_size](#input\_maximum\_scaling\_step\_size) | Maximum scaling step size | `number` | `2` | no |
| <a name="input_memory_for_kong_task"></a> [memory\_for\_kong\_task](#input\_memory\_for\_kong\_task) | Memory required for kong task definiton | `number` | `256` | no |
| <a name="input_minimum_scaling_step_size"></a> [minimum\_scaling\_step\_size](#input\_minimum\_scaling\_step\_size) | Minimum scaling step size | `number` | `1` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable performance insights | `bool` | `true` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | The retention period for performance insights | `number` | `7` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet id | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet id | `list(string)` | n/a | yes |
| <a name="input_rds_db_tags"></a> [rds\_db\_tags](#input\_rds\_db\_tags) | List of tags | `map(string)` | `{}` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | The instance class to use | `string` | `"db.t3.micro"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) Name of the SSL Policy for the listener. | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| <a name="input_target_capacity"></a> [target\_capacity](#input\_target\_capacity) | Target Capacity for managed scaling | `number` | `100` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

No outputs.
