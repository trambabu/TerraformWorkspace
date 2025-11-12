variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "bastion_allowed_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "open_ssh_to_world" {
  type    = bool
  default = false
}

# ✅ Correct variable name
variable "private_app_subnet_ids" {
  description = "List of Private App Subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "backend_app_s3_url" {
  type        = string
  description = "S3 URL of backend Spring Boot application JAR"
}

variable "bastion_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}
