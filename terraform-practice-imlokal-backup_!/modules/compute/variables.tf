variable "ssh_public_key" {
  type        = string
  description = "Public key contents to insert into authorized_keys on all instances (use file(...) at root)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_public_ids" {
  type        = list(string)
  description = "Public subnet ids (for bastion and ALB)"
}

variable "subnet_private_app_ids" {
  type        = list(string)
  description = "Private app subnet ids (for ASG)"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security Group ID for bastion"
}

variable "backend_sg_id" {
  type        = string
  description = "Security Group ID for backend instances"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type to use for launch templates"
}
