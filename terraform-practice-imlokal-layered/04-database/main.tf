provider "aws" { region = var.aws_region }
module "rds" {
  source          = "../modules/rds"
  db_username     = var.db_username
  db_password     = var.db_password
  db_subnet_ids   = var.db_subnet_ids
  db_sg_id        = var.db_sg_id
  enable_multi_az = var.enable_multi_az
}
#output "rds_endpoint" { value = module.rds.rds_endpoint }
