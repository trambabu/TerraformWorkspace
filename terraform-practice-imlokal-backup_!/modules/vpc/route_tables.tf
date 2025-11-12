variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }


resource "aws_route_table" "public" {
vpc_id = var.vpc_id
tags = { Name = "public-rt" }
}


resource "aws_route" "public_default" {
route_table_id = aws_route_table.public.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "public_assoc" {
count = length(var.public_subnet_ids)
subnet_id = var.public_subnet_ids[count.index]
route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" { vpc = true }


resource "aws_nat_gateway" "nat" {
allocation_id = aws_eip.nat.id
subnet_id = var.public_subnet_ids[0]
tags = { Name = "practice-nat" }
}


resource "aws_route_table" "private" {
vpc_id = var.vpc_id
tags = { Name = "private-rt" }
}


resource "aws_route" "private_default" {
route_table_id = aws_route_table.private.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id
}


resource "aws_route_table_association" "private_app_assoc" {
count = length(var.private_subnet_ids)
subnet_id = var.private_subnet_ids[count.index]
route_table_id = aws_route_table.private.id
}