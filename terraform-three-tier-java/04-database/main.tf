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

module "database" {
  source                 = "../modules/database"
  project_name           = var.project_name
  aws_region             = var.aws_region

  vpc_id                 = module.network.vpc_id
  private_db_subnet_ids  = module.network.private_db_subnet_ids

  db_sg_id               = module.security.db_sg_id

  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_instance_class      = var.db_instance_class
  multi_az               = var.multi_az
}