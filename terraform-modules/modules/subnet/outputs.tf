
output "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  value       = aws_subnet.public_subnet.cidr_block
}
output "public_subnet_id" {
     description = "The ID of the public subnet"
  value = aws_subnet.public_subnet.id
}
