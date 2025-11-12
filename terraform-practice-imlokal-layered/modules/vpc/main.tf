variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_app_subnet_cidrs" {
  type = list(string)
}

variable "private_db_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

locals {
  az_list = [
    for suffix in var.azs : "${var.aws_region}${suffix}"
  ]
}

# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "practice-vpc"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "practice-igw"
  }
}

# -------------------------------
# Public Subnets
# -------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index + 1}"
  }
}

# -------------------------------
# Private Subnets (Application Layer)
# -------------------------------
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = local.az_list[count.index]

  tags = {
    Name = "private-app-${count.index + 1}"
  }
}

# -------------------------------
# Private Subnets (Database Layer)
# -------------------------------
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = local.az_list[count.index]

  tags = {
    Name = "private-db-${count.index + 1}"
  }
}
