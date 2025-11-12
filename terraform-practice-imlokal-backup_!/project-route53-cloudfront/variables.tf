variable "aws_region" { type = string; default = "ap-south-1" }
variable "domain_name" { type = string; default = "imlokal.in" }

# ALB values pulled from project-ip-restricted outputs
variable "alb_dns_name" { type = string }
variable "alb_zone_id"  { type = string }

# CloudFront needs ACM cert in us-east-1. If you want Terraform to create the cert, leave this empty.
variable "acm_certificate_arn" {
  type        = string
  description = "If you already created an ACM cert in us-east-1, provide ARN; otherwise leave empty to let Terraform create it"
  default     = ""
}

variable "create_route53_zone" {
  type        = bool
  default     = true
  description = "If true, create a hosted zone in Route53 for domain and return NS to update at registrar"
}
