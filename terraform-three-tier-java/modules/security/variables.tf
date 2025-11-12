variable "vpc_id" { type = string }
variable "alb_subnet_ids" { type = list(string) }
variable "bastion_allowed_ip" { type = string }
variable "open_ssh_to_world" { type = bool }
variable "project_name" { type = string }
variable "aws_region" { type = string }
