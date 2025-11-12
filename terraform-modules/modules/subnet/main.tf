resource aws_subnet "public_subnet" {
    vpc_id            = var.vpc_id
    cidr_block       = var.public_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true # ✅ ensures EC2 gets a public IP
    tags = {
        Name = var.public_subnet_name
    }
}