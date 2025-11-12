terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source        = "../../modules/ec2"
  environment   = "staging"
  instance_type = var.instance_type
}
