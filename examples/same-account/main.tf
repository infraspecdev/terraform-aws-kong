provider "aws" {
  region = var.region
}


module "kong" {
  source = "../../"

  providers = {
    aws                        = aws
    aws.cross_account_provider = aws
  }

  vpc_id                        = var.vpc_id
  public_subnet_ids             = var.public_subnet_ids
  private_subnet_ids            = var.private_subnet_ids
  kong_public_domain_name       = var.kong_public_domain_name
  kong_admin_domain_name        = var.kong_admin_domain_name
  cluster_name                  = var.cluster_name
  postgres_engine_version       = var.postgres_engine_version
  postgres_major_engine_version = var.postgres_major_engine_version
  route53_assume_role_arn       = var.route53_assume_role_arn
}
