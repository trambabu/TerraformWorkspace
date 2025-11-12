variable "ssh_public_key" { type = string }
variable "vpc_id" { type = string }
variable "subnet_public_ids" { type = list(string) }
variable "subnet_private_app_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "backend_sg_id" { type = string }


# Key Pair
resource "aws_key_pair" "bastion_key" {
key_name = "practice-bastion-key"
public_key = var.ssh_public_key
}


# IAM role & instance profile for SSM
resource "aws_iam_role" "ssm_role" {
name = "practice-ssm-role"
assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
}


data "aws_iam_policy_document" "ssm_assume" {
statement { actions = ["sts:AssumeRole"]; principals { type = "Service"; identifiers = ["ec2.amazonaws.com"] } }
}


resource "aws_iam_role_policy_attachment" "ssm_attach" {
role = aws_iam_role.ssm_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ssm_profile" {
name = "practice-ssm-profile"
role = aws_iam_role.ssm_role.name
}


# Bastion instance
resource "aws_instance" "bastion" {
ami = data.aws_ami.amazon_linux.id
instance_type = "t3.micro"
subnet_id = var.subnet_public_ids[0]
key_name = aws_key_pair.bastion_key.key_name
vpc_security_group_ids = [var.bastion_sg_id]
iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
user_data = templatefile("${path.module}/../../templates/bastion_userdata.tpl", { ssh_pub = var.ssh_public_key })
tags = { Name = "bastion" }
}


# Launch templates for frontend & backend would be defined here, plus ASGs and ALBs – see project-level usage files.


data "aws_ami" "amazon_linux" {
owners = ["amazon"]
most_recent = true
filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}