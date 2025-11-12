output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
  description = "Public IP of the bastion host"
}

# If you create ASGs/ALBs inside module, output them too:
# output "frontend_alb_dns" { value = aws_lb.frontend_alb.dns_name }
# output "frontend_alb_zone_id" { value = aws_lb.frontend_alb.zone_id }
