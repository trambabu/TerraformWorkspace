variable "aws_region" { type = string; default = "ap-south-1" }
variable "ssh_public_key_path" { type = string; description = "Path to your public key file (example: C:/tf-keys/id_rsa_bastion.pub)" }
variable "bastion_allowed_ip" { type = string; default = "175.101.67.131/32" }
variable "open_ssh_to_world" { type = bool; default = false }
variable "db_username" { type = string; default = "admin" }
variable "db_password" { type = string; default = "ChangeMe123!" }
variable "domain_name" { type = string; default = "imlokal.in" }
