provider "aws" {
  region = "us-east-1"
}

variable "project_name" { default = "imlokal" }
variable "frontend_max" {
  default = 3
}
variable "frontend_min" {
  default = 1
}
variable "frontend_desired" {
  default = 2
}
variable "backend_max" {
  default = 3
}
variable "backend_min" {
  default = 1
}
variable "backend_desired" {
  default = 2
}
variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access to frontend instances"
  default     = "multitier.keypair"
}
variable "frontend_jar" {
  description = "S3 path to the frontend static website zip file"
  default     = "s3://imlokal-artifacts/templatemo_559_zay_shop.zip"
}
variable "backend_jar" {
  description = "S3 path to the Spring Boot backend JAR file"
  default     = "s3://imlokal-artifacts/orderservice-0.0.1-SNAPSHOT.jar"
}

variable "db_password" {
  description = "Password for the RDS MySQL 'appuser' user"
  type        = string
  sensitive   = true
  default = "StrongPass123!"
}



variable "frontend_instance_type" { default = "t3.micro" }
variable "backend_instance_type" { default = "t3.micro" }

variable "frontend_ami_id" {default = "ami-0c55b159cbfafe1f0"}
variable "backend_ami_id" {
    default = "ami-0c55b159cbfafe1f0"
    #default = "ami-0b2f6494ff0b07a0e"
}

variable "ssh_key_name" {
  description = "Only required if you want optional direct SSH to frontend"
  default     = ""
}
variable domain_name {
    default = "imlokal.in"
}           
variable create_route53_zone {
    default = true
}
variable create_cloudfront{
    default = true
}
variable hosted_zone_id {
    default = ""
}
# variable "ssh_cidr" {
#   description = "Only required if you want optional direct SSH to frontend"
#   default     = "0.0.0.0/0"
# }
