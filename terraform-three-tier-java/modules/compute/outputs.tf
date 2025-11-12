output "bastion_instance_id" { value = aws_instance.bastion.id }
output "app_instance_ids"    { value = aws_instance.app[*].id }
