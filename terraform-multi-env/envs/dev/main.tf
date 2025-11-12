terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source      = "../../modules/ec2"
  environment = "dev"
  instance_type = var.instance_type
}
