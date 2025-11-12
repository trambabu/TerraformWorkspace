provider "aws" {
  region = var.aws_region
}
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}
resource "aws_route53_zone" "zone" { name = var.domain_name }
resource "aws_acm_certificate" "cf_cert" {
  provider                  = aws.useast1
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}
resource "aws_acm_certificate_validation" "cf_validation" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "practice-frontend-static-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "random_id" "bucket_id" { byte_length = 4 }
resource "aws_cloudfront_distribution" "cf" {
  provider = aws.useast1
  enabled  = true

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cf_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases             = [var.domain_name, "www.${var.domain_name}"]
  default_root_object = "index.html"
}
resource "aws_route53_record" "root_alias_cf" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "app_alb" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "app.${var.domain_name}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
#output "route53_name_servers" { value = aws_route53_zone.zone.name_servers }
#output "cloudfront_domain" { value = aws_cloudfront_distribution.cf.domain_name }
