variable "vpc_id" { type = string }
variable "bastion_allowed_ip" { type = string }
variable "open_ssh_to_world" { type = bool }


resource "aws_security_group" "alb_sg" {
name = "alb-sg"
vpc_id = var.vpc_id
description = "ALB SG allow HTTP/HTTPS"
ingress { from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
ingress { from_port=443; to_port=443; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}


resource "aws_security_group" "backend_sg" {
name = "backend-sg"
vpc_id = var.vpc_id
description = "Allow traffic from ALB"
ingress {
from_port = 8080
to_port = 8080
protocol = "tcp"
security_groups = [aws_security_group.alb_sg.id]
}
egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}


resource "aws_security_group" "bastion_sg" {
name = "bastion-sg"
vpc_id = var.vpc_id
description = "Bastion SG"
ingress {
from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = [var.bastion_allowed_ip]
description = "SSH from your IP"
}
# optional open to world rule
resource "open_rule" "ssh_world" {}
egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}


resource "aws_security_group_rule" "ssh_world_rule" {
count = var.open_ssh_to_world ? 1 : 0
type = "ingress"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
security_group_id = aws_security_group.bastion_sg.id
}


resource "aws_security_group" "db_sg" {
name = "db-sg"
vpc_id = var.vpc_id
ingress { from_port = 3306; to_port = 3306; protocol = "tcp"; security_groups = [aws_security_group.backend_sg.id] }
egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}