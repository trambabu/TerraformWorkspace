module "cloudfront" {
  source = "../modules/cloudfront"
  alb_dns_name = var.alb_dns_name
  project_name = var.project_name
  certificate_arn = var.certificate_arn
}
