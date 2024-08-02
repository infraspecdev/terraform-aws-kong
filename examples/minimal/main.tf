module "kong" {
  source = "../../"

  vpc_id                  = var.vpc_id
  public_subnet_ids       = var.public_subnet_ids
  private_subnet_ids      = var.private_subnet_ids
  kong_public_domain_name = var.kong_public_domain_name
  kong_admin_domain_name  = var.kong_admin_domain_name
}
