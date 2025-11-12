environment  = "dev"
project_name = "imlokal"
aws_region   = "ap-south-1"

# Always use full AZ names
availability_zones = ["ap-south-1a", "ap-south-1b"]

backend_bucket     = "tf-backend-rambabu"
backend_lock_table = "tf-backend-lock"

vpc_cidr                 = "10.0.0.0/16"
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

enable_nat_gateway = true
