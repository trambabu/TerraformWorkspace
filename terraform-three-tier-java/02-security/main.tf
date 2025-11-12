module "network" {
  source       = "../modules/network"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "security" {
  source             = "../modules/security"
  project_name       = var.project_name
  aws_region         = var.aws_region

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids

  bastion_allowed_ip = var.bastion_allowed_ip
  open_ssh_to_world  = var.open_ssh_to_world
}