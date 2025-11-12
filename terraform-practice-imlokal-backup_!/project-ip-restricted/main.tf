terraform {
required_providers { aws = { source = "hashicorp/aws" } }
}


provider "aws" { region = "ap-south-1" }


module "vpc" {
source = "../modules/vpc"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24","10.0.12.0/24"]
private_db_subnet_cidrs = ["10.0.21.0/24","10.0.22.0/24"]
azs = ["a","b"]
aws_region = "ap-south-1"
}


module "security" {
source = "../modules/security"
vpc_id = module.vpc.aws_vpc_id
bastion_allowed_ip = "175.101.67.131/32"
open_ssh_to_world = false
}


module "compute" {
source = "../modules/compute"
ssh_public_key = file("../terraform.tfvars.pub")
vpc_id = module.vpc.aws_vpc_id
subnet_public_ids = module.vpc.public_subnet_ids
subnet_private_app_ids = module.vpc.private_app_subnet_ids
bastion_sg_id = module.security.bastion_sg_id
backend_sg_id = module.security.backend_sg_id
}


module "rds" {
source = "../modules/rds"
db_username = var.db_username
db_password = var.db_password
db_subnet_ids = module.vpc.private_db_subnet_ids
db_sg_id = module.security.db_sg_id
enable_multi_az = false
}
output "bastion_public_ip" { value = module.compute.bastion_public_ip }
output "rds_endpoint" { value = module.rds.db_endpoint }