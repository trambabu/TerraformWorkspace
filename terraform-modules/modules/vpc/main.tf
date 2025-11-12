resource "aws_vpc" "terraformvpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpc_name
    }
}