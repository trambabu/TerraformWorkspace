aws_region          = "ap-south-2"
vpc_cidr            = "10.0.0.0/16"
vpc_name            = "terraformVPC"
public_subnet_cidr  = "10.0.1.0/24"
availability_zone   = "ap-south-2a"

ami_id              = "ami-0b799c7efb5a188b9"
instance_type       = "t3.micro"
instance_name       = "terraform-ec2-instance"
public_subnet_name = "PublicSubnet"
security_group_name        = "PublicSecurityGroup"
security_group_description = "Security group for public access"
# To use Elastic IP:
assign_elastic_ip  = false # Set to true to assign Elastic IP : To use a normal dynamic public IP: set to false

tags = {
  Name        = "MyEC2Instance"
  Environment = "Dev"
  Project     = "Demo"
}
