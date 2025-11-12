output "bastion_public_ip" { value = module.compute.bastion_public_ip }
output "frontend_alb_dns" { value = module.compute.frontend_alb_dns }
output "frontend_alb_zone_id" { value = module.compute.frontend_alb_zone_id }
