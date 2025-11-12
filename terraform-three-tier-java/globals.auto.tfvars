# #############################################################################
# # Root orchestration - main.tf
# # Creates modules in order and wires outputs -> inputs between modules
# #############################################################################

# module "network" {
#   source                   = "./01-network"
#   project_name             = var.project_name
#   aws_region               = var.aws_region
#   vpc_cidr                 = var.vpc_cidr
#   public_subnet_cidrs      = var.public_subnet_cidrs
#   private_app_subnet_cidrs = var.private_app_subnet_cidrs
#   private_db_subnet_cidrs  = var.private_db_subnet_cidrs
#   availability_zones       = var.availability_zones
#   enable_nat_gateway       = var.enable_nat_gateway
# }

# # Pass outputs from module.network into security
# module "security" {
#   source                  = "./02-security"
#   project_name            = var.project_name
#   aws_region              = var.aws_region
#   vpc_id                  = module.network.vpc_id
#   public_subnet_ids       = module.network.public_subnet_ids
#   private_app_subnet_ids  = module.network.private_app_subnet_ids
#   bastion_allowed_ip      = var.bastion_allowed_ip
#   open_ssh_to_world       = var.open_ssh_to_world
# }

# # Compute gets VPC + subnets + SGs from network + security
# module "compute" {
#   source                 = "./03-compute"
#   project_name           = var.project_name
#   aws_region             = var.aws_region
#   vpc_id                 = module.network.vpc_id
#   public_subnet_ids      = module.network.public_subnet_ids
#   private_subnet_ids     = module.network.private_app_subnet_ids
#   bastion_sg_id          = module.security.bastion_sg_id
#   app_sg_id              = module.security.app_sg_id
#   key_name               = var.key_name
#   instance_type          = var.instance_type
#   asg_desired_capacity   = var.asg_desired_capacity
#   asg_min_size           = var.asg_min_size
#   asg_max_size           = var.asg_max_size
# }

# # DB receives private DB subnets and db security group from security module
# module "database" {
#   source                = "./04-database"
#   project_name          = var.project_name
#   aws_region            = var.aws_region
#   vpc_id                = module.network.vpc_id
#   private_db_subnet_ids = module.network.private_db_subnet_ids
#   db_sg_id              = module.security.db_sg_id
#   db_engine             = var.db_engine
#   db_engine_version     = var.db_engine_version
#   db_instance_class     = var.db_instance_class
#   db_name               = var.db_name
#   db_username           = var.db_username
#   db_password           = var.db_password
#   multi_az              = var.multi_az
# }

# # CloudFront + Route53 needs ALB DNS from compute
# module "cloudfront" {
#   source         = "./05-route53-cloudfront"
#   project_name   = var.project_name
#   aws_region     = var.aws_region
#   alb_dns_name   = module.compute.alb_dns_name
#   domain_name    = var.domain_name
#   hosted_zone_id = var.hosted_zone_id
#   certificate_arn = var.certificate_arn_us_east_1
# }
#############################################################################
# Root orchestration - main.tf
# Creates modules in order and wires outputs -> inputs between modules
#############################################################################

module "network" {
  source                   = "./01-network"
  project_name             = var.project_name
  aws_region               = var.aws_region
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  availability_zones       = var.availability_zones
  enable_nat_gateway       = var.enable_nat_gateway
}

# Pass outputs from module.network into security
module "security" {
  source                  = "./02-security"
  project_name            = var.project_name
  aws_region              = var.aws_region
  vpc_id                  = module.network.vpc_id
  public_subnet_ids       = module.network.public_subnet_ids
  private_app_subnet_ids  = module.network.private_app_subnet_ids
  bastion_allowed_ip      = var.bastion_allowed_ip
  open_ssh_to_world       = var.open_ssh_to_world
}

# Compute gets VPC + subnets + SGs from network + security
module "compute" {
  source                 = "./03-compute"
  project_name           = var.project_name
  aws_region             = var.aws_region
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_app_subnet_ids
  bastion_sg_id          = module.security.bastion_sg_id
  app_sg_id              = module.security.app_sg_id
  key_name               = var.key_name
  instance_type          = var.instance_type
  asg_desired_capacity   = var.asg_desired_capacity
  asg_min_size           = var.asg_min_size
  asg_max_size           = var.asg_max_size
}

# DB receives private DB subnets and db security group from security module
module "database" {
  source                = "./04-database"
  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.network.vpc_id
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_sg_id              = module.security.db_sg_id
  db_engine             = var.db_engine
  db_engine_version     = var.db_engine_version
  db_instance_class     = var.db_instance_class
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  multi_az              = var.multi_az
}

# CloudFront + Route53 needs ALB DNS from compute
module "cloudfront" {
  source         = "./05-route53-cloudfront"
  project_name   = var.project_name
  aws_region     = var.aws_region
  alb_dns_name   = module.compute.alb_dns_name
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  certificate_arn = var.certificate_arn_us_east_1
}
