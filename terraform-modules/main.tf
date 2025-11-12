# Create a VPC
module vpc {
  source    = "./modules/vpc"
  vpc_name  = var.vpc_name
  vpc_cidr  = var.vpc_cidr
 # vpc_id    = var.vpc.vpc_id
  aws_region = var.aws_region
}
# Create a Subnet
module subnet {
  source              = "./modules/subnet"
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr
  availability_zone   = var.availability_zone
  public_subnet_name  = var.public_subnet_name
}
# Create a Security Group
module security_group {
  source                     = "./modules/securityGroup"
  vpc_id                     = module.vpc.vpc_id
  #security_group_id         = var.security_group_id
  security_group_name        = var.security_group_name
  security_group_description = var.security_group_description
   # 👇 Pass ports dynamically here
  ingress_ports = [22, 80, 443]
  tags                       = var.tags
}

############################################
# Fetch Latest Amazon Linux 2 AMI
############################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create an EC2 Instance
module ec2 {
  source         = "./modules/ec2"
  ami_id             = data.aws_ami.amazon_linux_2.id   # auto fetch latest AMI
  #ami_id         = var.ami_id
  instance_type  = var.instance_type
  public_subnet_id      = module.subnet.public_subnet_id
  security_group_id = module.security_group.security_group_id
  instance_name  = var.instance_name
  assign_elastic_ip  = var.assign_elastic_ip  # ✅ add this
}

