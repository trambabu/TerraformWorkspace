############################
# random suffix for S3 bucket
############################
resource "random_id" "bucket_suffix" {
  byte_length = 3
}

############################
# S3 bucket for artifacts
############################
resource "aws_s3_bucket" "artifacts" {
  bucket = "imlokal-artifacts-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "imlokal-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts_ver" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_enc" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

############################
# NETWORK: VPC, subnets, IGW, NAT
############################
data "aws_availability_zones" "azs" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "imlokal-vpc" }
}

# 2 public subnets (we'll place ALBs & frontend ASG here)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  tags                    = { Name = "imlokal-public-${count.index}" }
}

# 2 private subnets (backend & DB)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 11)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags              = { Name = "imlokal-private-${count.index}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "imlokal-igw" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "imlokal-public-rt"
  }
}
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "imlokal-private-rt" }
}
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

############################
# SECURITY GROUPS
############################
# ALB SG - allows 80/443 from internet
resource "aws_security_group" "alb_sg" {
  name        = "imlokal-alb-sg"
  description = "Allow HTTP/HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "imlokal-alb-sg" }
}

# EC2 SG - only accept traffic from ALB SG (frontend: port 80 ; backend: 8080)
resource "aws_security_group" "ec2_frontend_sg" {
  name   = "imlokal-ec2-frontend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "ALB_frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # allow SSM agent (https to SSM endpoints) outgoing - default egress allows all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "imlokal-ec2-frontend-sg"
  }
}

resource "aws_security_group" "ec2_backend_sg" {
  name   = "imlokal-ec2-backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "ALB_backend"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "imlokal-ec2-backend-sg" }
}

# RDS SG - only allow backend SG to access 3306
resource "aws_security_group" "rds_sg" {
  name   = "imlokal-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "backend_rds"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "imlokal-rds-sg" }
}

############################
# IAM Role & Instance Profile (SSM + S3 read)
############################
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "imlokal-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "imlokal-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

############################
# Launch Templates (user-data uses templatefile to insert bucket name & jar)
############################
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "frontend_lt" {
  name_prefix   = "imlokal-frontend-lt-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.frontend_instance_type
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  vpc_security_group_ids = [aws_security_group.ec2_frontend_sg.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  user_data = base64encode(
    templatefile("${path.module}/userdata/frontend.sh", {
      bucket   = aws_s3_bucket.artifacts.bucket,
      filename = var.frontend_jar
    })
  )
}

resource "aws_launch_template" "backend_lt" {
  name_prefix   = "imlokal-backend-lt-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.backend_instance_type
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  vpc_security_group_ids = [aws_security_group.ec2_backend_sg.id]
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  user_data = base64encode(
    templatefile("${path.module}/userdata/backend.sh", {
      bucket   = aws_s3_bucket.artifacts.bucket,
      filename = var.backend_jar
    })
  )
}

############################
# ASG for frontend (attached to frontend target group later)
############################


############################
# RDS: simple MySQL (basic) in private subnets
############################
resource "aws_db_subnet_group" "rds_subs" {
  name       = "imlokal-rds-subnets"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "mysql" {
  identifier             = "imlokal-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "appuser"
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subs.name
  publicly_accessible    = false
  multi_az               = false
  tags                   = { Name = "imlokal-mysql" }
}

############################
# ALBs, target groups, listeners
############################
# Frontend ALB
resource "aws_lb" "frontend_alb" {
  name               = "imlokal-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
  tags               = { Name = "imlokal-frontend-alb" }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "imlokal-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path     = "/health.html"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_autoscaling_group" "frontend_asg" {
  name             = "${var.project_name}-frontend-asg"
  max_size         = var.frontend_max
  min_size         = var.frontend_min
  desired_capacity = var.frontend_desired

  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-frontend"
    propagate_at_launch = true
  }
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# Backend ALB
resource "aws_lb" "backend_alb" {
  name               = "imlokal-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
  tags               = { Name = "imlokal-backend-alb" }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "imlokal-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path     = "/actuator/health"
    matcher  = "200-399"
    interval = 30
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name             = "${var.project_name}-backend-asg"
  max_size         = var.backend_max
  min_size         = var.backend_min
  desired_capacity = var.backend_desired

  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend"
    propagate_at_launch = true
  }
}

resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

############################
# Route53 zone (create) — we create hosted zone for domain
############################
resource "aws_route53_zone" "zone" {
  name = var.domain_name
}

############################
# ACM certificate in us-east-1 for CloudFront
############################
resource "aws_acm_certificate" "cf_cert" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = { Name = "imlokal-cf-cert" }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cf_cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

############################
# CloudFront distribution pointing to frontend ALB
############################
resource "aws_cloudfront_distribution" "cf" {
  enabled = true
  aliases = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name = aws_lb.frontend_alb.dns_name
    origin_id   = "frontend-alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "frontend-alb-origin"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cf_cert.arn
    ssl_support_method  = "sni-only"
  }

  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

############################
# Route53 records mapping apex & www to CloudFront and api to backend ALB
############################
resource "aws_route53_record" "apex_alias" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_alias" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
  }
}

