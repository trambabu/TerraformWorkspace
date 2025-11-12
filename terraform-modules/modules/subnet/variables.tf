variable "public_subnet_name" {
    description = "The name of the subnet"
    type        = string
}

variable "public_subnet_cidr" {
    description = "The CIDR block for the public subnet"
    type        = string
}

variable "availability_zone" {
    description = "The availability zone for the subnet"
    type        = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}