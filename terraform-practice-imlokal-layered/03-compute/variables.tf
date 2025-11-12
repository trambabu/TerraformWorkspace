variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_app_subnet_ids" {
  type = list(string)
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_imlokal.pub"
}
variable "bastion_sg_id" {
  type = string
}
variable "backend_sg_id" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "backend_app_s3_url" {
  type    = string
  default = ""
}
variable "frontend_sg_id" {
  type    = string
  default = data.terraform_remote_state.security.outputs.frontend_sg_id
  #frontend_sg_id = data.terraform_remote_state.security.outputs.frontend_sg_id

}
