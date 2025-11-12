data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "practice-bastion-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_public_ids[0]
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [var.bastion_sg_id]
  user_data              = file("${path.module}/../../user-data/bastion_userdata.sh")

  tags = { Name = "practice-bastion" }
}

# ----------------- FRONTEND ALB -----------------

resource "aws_lb" "frontend_alb" {
  name               = "practice-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.frontend_sg_id]
  subnets            = var.subnet_public_ids

  tags = { Name = "frontend-alb" }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    matcher  = "200-399"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_launch_template" "frontend_lt" {
  name_prefix            = "frontend-lt-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  user_data              = file("${path.module}/../../user-data/frontend_userdata.sh")
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [var.frontend_sg_id]
}

resource "aws_autoscaling_group" "frontend_asg" {
  name                = "frontend-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_private_app_ids

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend_tg.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "frontend-instance"
    propagate_at_launch = true
  }
}

# ----------------- BACKEND -----------------

resource "aws_lb" "backend_alb" {
  name               = "practice-backend-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.subnet_private_app_ids

  tags = { Name = "backend-alb" }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/actuator/health"
    protocol = "HTTP"
  }
}

resource "aws_launch_template" "backend_lt" {
  name_prefix   = "backend-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/../../user-data/backend_userdata.sh.tpl", {
    app_s3 = var.backend_app_s3_url
  })

  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [var.backend_sg_id]
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = "backend-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_private_app_ids

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "backend-instance"
    propagate_at_launch = true
  }
}
