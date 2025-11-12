variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
variable "aws_region" { type = string }


locals {
az_list = [for s in var.azs : "${var.aws_region}${s}"]
}


resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr
enable_dns_hostnames = true
enable_dns_support = true
tags = { Name = "practice-vpc" }
}


resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main.id
tags = { Name = "practice-igw" }
}


resource "aws_subnet" "public" {
count = length(var.public_subnet_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.public_subnet_cidrs[count.index]
availability_zone = local.az_list[count.index]
map_public_ip_on_launch = true
tags = { Name = "public-${count.index+1}" }
}


resource "aws_subnet" "private_app" {
count = length(var.private_app_subnet_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.private_app_subnet_cidrs[count.index]
availability_zone = local.az_list[count.index]
tags = { Name = "private-app-${count.index+1}" }
}


resource "aws_subnet" "private_db" {
count = length(var.private_db_subnet_cidrs)
vpc_id = aws_vpc.main.id
cidr_block = var.private_db_subnet_cidrs[count.index]
availability_zone = local.az_list[count.index]
tags = { Name = "private-db-${count.index+1}" }
}