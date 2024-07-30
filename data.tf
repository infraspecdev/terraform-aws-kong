data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ssm_parameter" "rds" {
  for_each        = toset(local.rds_parameters)
  name            = "/rds/${each.value}"
  with_decryption = true
}

data "aws_ssm_parameter" "github" {
  for_each        = toset(local.github_parameters)
  name            = "/github-action/${each.value}"
  with_decryption = true
}

data "aws_autoscaling_group" "this" {
  name = var.asg_name
}
