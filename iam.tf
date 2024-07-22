module "ecs_task_role" {
  source                = "./modules/iam"
  name_prefix           = "ecs-task-role"
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  policy_arns           = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

module "ecs_exec_role" {
  source                = "./modules/iam"
  name_prefix           = "ecs-exec-role"
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  policy_arns           = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}
