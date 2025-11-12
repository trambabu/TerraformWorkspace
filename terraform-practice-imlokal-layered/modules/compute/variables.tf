variable "ssh_public_key" { type = string }
variable "vpc_id" { type = string }
variable "subnet_public_ids" { type = list(string) }
variable "subnet_private_app_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "backend_sg_id" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "backend_app_s3_url" {
  type    = string
  default = ""
}
variable "ssh_public_key" { type = string }
variable "vpc_id" { type = string }
variable "subnet_public_ids" { type = list(string) }
variable "subnet_private_app_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "backend_sg_id" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "backend_app_s3_url" {
  type    = string
  default = ""
}
variable "frontend_sg_id" {
  type = string
}