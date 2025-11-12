variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "app_sg_id" { type = string }
variable "project_name" { type = string }
