variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for public subnets"
  default     = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for private app subnets"
  default     = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for private DB subnets"
  default     = ["10.0.21.0/24","10.0.22.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "AZ suffixes to use (e.g. [\"a\",\"b\"])"
  default     = ["a","b"]
}

variable "aws_region" {
  type        = string
  description = "AWS region for this VPC"
  default     = "ap-south-1"
}
