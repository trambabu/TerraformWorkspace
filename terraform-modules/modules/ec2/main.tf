############################################
# EC2 Instance
############################################
resource "aws_instance" "terraform_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = var.assign_elastic_ip ? false : true
  # ^ if Elastic IP is enabled, we disable auto public IP (we’ll attach EIP manually)

  tags = {
    Name = var.instance_name
  }
}

############################################
# Elastic IP (optional)
############################################
resource "aws_eip" "ec2_eip" {
  count    = var.assign_elastic_ip ? 1 : 0   # ✅ create only if enabled
  instance = aws_instance.terraform_ec2.id

  tags = {
    Name = "${var.instance_name}-EIP"
  }

  lifecycle {
    prevent_destroy = false   # ✅ ensures Terraform releases it automatically
  }
}
