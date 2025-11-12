output "route53_name_servers" { value = aws_route53_zone.zone.name_servers }
output "cloudfront_domain" { value = aws_cloudfront_distribution.cf.domain_name }