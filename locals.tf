locals {

  ssm_parameters = {
    rds = [
      "POSTGRES_USERNAME",
      "POSTGRES_PASSWORD",
      "POSTGRES_DB_NAME"
    ]
    github = [
      "GITHUB_ORG",
      "GITHUB_REPO",
      "GITHUB_TOKEN"
    ]
  }

  rds = {
    name                 = "kong-postgres"
    db_identifier        = "kong-postgres-01"
    engine               = "postgres"
    storage_encrypted    = true
    storage_type         = "gp3"
    engine_version       = 16.3
    engine_family        = "postgres16"
    major_engine_version = 16
    port                 = 5432
    sg_name              = "kong-postgres"
    sg_description       = "Allow all traffic within vpc"
    postgres_username    = data.aws_ssm_parameter.rds["POSTGRES_USERNAME"].value
    postgres_password    = data.aws_ssm_parameter.rds["POSTGRES_PASSWORD"].value
    postgres_db_name     = data.aws_ssm_parameter.rds["POSTGRES_DB_NAME"].value
  }

  ecs = {
    iam = {
      name_prefix           = "kong-ecs-exec"
      ecs_exec_policy_arn   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
      principal_type        = "Service"
      principal_identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

  kong = {
    name                   = "kong"
    service_name           = "kong"
    task_definition_family = "kong"
    network_mode           = "awsvpc"
    alb_sg_name            = "kong"
    ecs_task_sg_name       = "kong"
    commands               = ["/bin/sh", "-c", "kong migrations bootstrap && ulimit -n 4096 && kong start"]

    public_target_group   = "kong_public"
    internal_target_group = "kong_internal"

    admin_port = 8001
    proxy_port = 8000
    portMappings = [
      { containerPort = 80, hostPort = 80 },
      { containerPort = 8000, hostPort = 8000 },
      { containerPort = 8001, hostPort = 8001 },
    ]

    environment = {
      "KONG_ADMIN_LISTEN"     = "0.0.0.0:8001"
      "KONG_PROXY_LISTEN"     = "0.0.0.0:8000"
      "KONG_DATABASE"         = local.rds.engine
      "KONG_PG_HOST"          = module.kong_rds.db_instance_address
      "KONG_PG_USER"          = local.rds.postgres_username
      "KONG_PG_PASSWORD"      = local.rds.postgres_password
      "KONG_PG_DATABASE"      = local.rds.postgres_db_name
      "KONG_PROXY_ACCESS_LOG" = "/dev/stdout"
      "KONG_ADMIN_ACCESS_LOG" = "/dev/stdout"
      "KONG_PROXY_ERROR_LOG"  = "/dev/stderr"
      "KONG_ADMIN_ERROR_LOG"  = "/dev/stderr"
      "KONG_LOG_LEVEL"        = "debug"
      "KONG_PG_SSL"           = "on"
    }
  }

  github = {
    org   = data.aws_ssm_parameter.github["GITHUB_ORG"].value
    repo  = data.aws_ssm_parameter.github["GITHUB_REPO"].value
    token = data.aws_ssm_parameter.github["GITHUB_TOKEN"].value
  }

  default_tags = {
    ManagedBy = "Terraform"
  }
}
