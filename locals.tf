locals {
  name              = "kong-postgres"
  db_identifier     = "${local.name}-01"
  rds_engine        = "postgres"
  storage_encrypted = true
  storage_type      = "gp3"

  postgres = {
    engine_version       = 16.3
    engine_family        = "postgres16"
    major_engine_version = 16
    port                 = 5432
  }

  ecs = {
    user_data        = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config;
    EOF
    ecs_node_sg_name = "kong"
  }

  kong = {
    name                   = "kong"
    service_name           = "kong"
    task_definition_family = "kong"
    network_mode           = "awsvpc"
    launch_template_name   = "kong"
    image_id               = data.aws_ssm_parameter.ecs_node_ami.value
    iam_role_policy_attachments = [
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    ]

    alb_sg_name      = "kong"
    ecs_task_sg_name = "kong"
    commands         = ["/bin/sh", "-c", "kong migrations bootstrap && ulimit -n 4096 && kong start"]

    portMappings = [
      { containerPort = 80, hostPort = 80 },
      { containerPort = 8000, hostPort = 8000 },
      { containerPort = 8443, hostPort = 8443 },
      { containerPort = 8001, hostPort = 8001 },
      { containerPort = 8002, hostPort = 8002 }
    ]


    admin_port            = 8001
    proxy_port            = 8000
    public_target_group   = "kong_public"
    internal_target_group = "kong_internal"
    public_domains        = [for subdomain in var.kong_public_sub_domain_names : "${subdomain}.${var.base_domain}"]
    admin_domains         = [for subdomain in var.kong_admin_sub_domain_names : "${subdomain}.${var.base_domain}"]
  }

  rds_parameters = [
    "POSTGRES_USERNAME",
    "POSTGRES_PASSWORD",
    "POSTGRES_DB_NAME"
  ]

  github_parameters = [
    "CONFIG_TOKEN",
    "CONFIG_URL"
  ]

  postgres_username   = data.aws_ssm_parameter.rds["POSTGRES_USERNAME"].value
  postgres_password   = data.aws_ssm_parameter.rds["POSTGRES_PASSWORD"].value
  postgres_db_name    = data.aws_ssm_parameter.rds["POSTGRES_DB_NAME"].value
  github_config_token = data.aws_ssm_parameter.github["CONFIG_TOKEN"].value
  github_config_url   = data.aws_ssm_parameter.github["CONFIG_URL"].value

  kong_parameters = {
    "KONG_ADMIN_LISTEN"     = "0.0.0.0:8001"
    "KONG_PROXY_LISTEN"     = "0.0.0.0:8000"
    "KONG_DATABASE"         = local.rds_engine
    "KONG_PG_HOST"          = module.kong_rds.db_instance_address
    "KONG_PG_USER"          = local.postgres_username
    "KONG_PG_PASSWORD"      = local.postgres_password
    "KONG_PG_DATABASE"      = local.postgres_db_name
    "KONG_PROXY_ACCESS_LOG" = "/dev/stdout"
    "KONG_ADMIN_ACCESS_LOG" = "/dev/stdout"
    "KONG_PROXY_ERROR_LOG"  = "/dev/stderr"
    "KONG_ADMIN_ERROR_LOG"  = "/dev/stderr"
    "KONG_LOG_LEVEL"        = "debug"
    "KONG_PG_SSL"           = "on"
  }

  default_tags = {
    ManagedBy = "Terraform"
  }
}
