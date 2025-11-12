############################################################
# VARIABLES
############################################################

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  default     = "trambabu_rsa_aws_key" # Change as per your key pair name
}

############################################################
# IAM ROLE + INSTANCE PROFILE FOR CLOUDWATCH
############################################################

# Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2CloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS managed CloudWatch policy
resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2CloudWatchInstanceProfile"
  role = aws_iam_role.ec2_role.name
}

############################################################
# VPC SETUP
############################################################
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = { Name = "CustomVPC-IGW" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = { Name = "PublicSubnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = { Name = "PublicRouteTable" }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

############################################################
# SECURITY GROUP
############################################################
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "EC2SecurityGroup" }
}

############################################################
# DATA SOURCE: AMAZON LINUX 2 AMI
############################################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################################################
# EC2 INSTANCE + CLOUDWATCH AGENT SETUP
############################################################
# resource "aws_key_pair" "default" {
#   key_name   = "trambabu_git_rsa_key"
#   public_key = file("~/.ssh/trambabu_git_rsa_key.pub")
# }
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent

              cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              {
                "agent": {
                  "metrics_collection_interval": 60,
                  "run_as_user": "root"
                },
                "metrics": {
                  "append_dimensions": {
                    "InstanceId": "\$${aws:InstanceId}"   # Use double $$ to escape in user_data
                  },
                  "metrics_collected": {
                    "mem": {
                      "measurement": [
                        {"name": "mem_used_percent", "rename": "MemoryUsedPercent", "unit": "Percent"}
                      ]
                    },
                    "cpu": {
                      "measurement": [
                        {"name": "cpu_usage_idle", "rename": "CPUIdle", "unit": "Percent"}
                      ],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }
              EOT

              systemctl enable amazon-cloudwatch-agent
              systemctl start amazon-cloudwatch-agent
              EOF

  tags = {
    Name = "EC2-With-CloudWatch"
  }
}

############################################################
# NULL RESOURCE TO VERIFY CLOUDWATCH AGENT STATUS
############################################################
resource "null_resource" "verify_cloudwatch_agent" {
  depends_on = [aws_instance.ec2_instance]

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl status amazon-cloudwatch-agent || echo 'CloudWatch agent status check failed'",
      "echo 'Verification done!'"
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.ec2_instance.public_ip
      user        = "ec2-user"
      private_key = file("C:/Users/USER/.ssh/trambabu_rsa_aws_key.pem")
      #private_key = file(pathexpand("~/.ssh/trambabu_git_rsa_key"))

    }
  }
}

############################################################
# OUTPUTS
############################################################
output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}
