data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ssm_parameter" "rds" {
  for_each        = toset(local.ssm_parameters.rds)
  name            = "/rds/${each.value}"
  with_decryption = true
}

data "aws_ssm_parameter" "github" {
  for_each        = toset(local.ssm_parameters.github)
  name            = "/github-action/${each.value}"
  with_decryption = true
}

data "aws_autoscaling_group" "this" {
  name = var.asg_name
}
