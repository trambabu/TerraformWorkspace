output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.publicSecurityGroup.id
}
output "security_group_name" {
  description = "The name of the created security group"
  value       = aws_security_group.publicSecurityGroup.name
}