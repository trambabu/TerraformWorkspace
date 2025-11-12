resource "aws_security_group" "publicSecurityGroup" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  # ✅ Dynamic ingress rule generator
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # ✅ Egress (allow all outbound)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
