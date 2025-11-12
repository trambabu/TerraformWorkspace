variable "environment" { type = string }
variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "availability_zones" { type = list(string) }

variable "backend_bucket" { type = string }
variable "backend_lock_table" { type = string }

variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }

variable "enable_nat_gateway" {
  type    = bool
  default = false
}
