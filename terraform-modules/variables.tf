variable "aws_region" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "availability_zone" {}
variable "public_subnet_name" {}

variable "ami_id" {}
variable "instance_type" {}
variable "instance_name" {}
variable "security_group_name" {}
variable "security_group_description" {}
variable "assign_elastic_ip" {
  description = "If true, assign Elastic IP instead of dynamic public IP"
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}
