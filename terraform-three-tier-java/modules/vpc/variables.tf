variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
variable "enable_nat_gateway" { type = bool }
#variable "project_name" { type = string }
variable "aws_region" { type = string }
