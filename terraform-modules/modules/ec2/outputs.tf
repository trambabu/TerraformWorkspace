output "instance_id" {
  value = aws_instance.terraform_ec2.id
}

output "public_ip" {
  value = aws_instance.terraform_ec2.public_ip
}

# Dynamic public IP or EIP depending on configuration
output "ec2_public_ip" {
  value = var.assign_elastic_ip ? aws_eip.ec2_eip[0].public_ip : aws_instance.terraform_ec2.public_ip
}
