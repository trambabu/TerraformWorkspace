variable "vpc_id" {
  type = string
}

variable "bastion_allowed_ip" {
  type        = string
  description = "Your public IP in CIDR notation (ex: 175.101.67.131/32)"
}

variable "open_ssh_to_world" {
  type    = bool
  default = false
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Backend Security Group
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  vpc_id      = var.vpc_id
  description = "Security group for backend servers"

  ingress {
    description     = "Allow ALB to reach backend app"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = var.vpc_id
  description = "Security group for Bastion Host"

  ingress {
    description = "Allow SSH from your personal IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# Optional — Open SSH to world if explicitly enabled
resource "aws_security_group_rule" "ssh_world_rule" {
  count = var.open_ssh_to_world ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  vpc_id      = var.vpc_id
  description = "Security group for RDS/MySQL"

  ingress {
    description     = "Allow backend servers to connect to DB"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}
