module "network" {
  source       = "../modules/network"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "security" {
  source       = "../modules/security"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "compute" {
  source               = "../modules/compute"
  project_name         = var.project_name
  aws_region           = var.aws_region

  vpc_id               = module.network.vpc_id
  private_app_subnet_ids = module.network.private_app_subnet_ids

  ec2_instance_type    = var.ec2_instance_type
  ec2_key_name         = var.ec2_key_name

  app_sg_id            = module.security.app_sg_id
}