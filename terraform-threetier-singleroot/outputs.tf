output "s3_artifacts_bucket" { value = aws_s3_bucket.artifacts.bucket }
output "cloudfront_domain" { value = aws_cloudfront_distribution.cf.domain_name }
output "frontend_alb" { value = aws_lb.frontend_alb.dns_name }
output "backend_alb" { value = aws_lb.backend_alb.dns_name }
output "route53_nameservers" { value = aws_route53_zone.zone.name_servers }
############################
# Outputs
############################

output "frontend_alb_dns" { value = aws_lb.frontend_alb.dns_name }
output "backend_alb_dns" { value = aws_lb.backend_alb.dns_name }


output "rds_endpoint" { value = aws_db_instance.mysql.address }
