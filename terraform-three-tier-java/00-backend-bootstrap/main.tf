terraform {
  backend "s3" {
    bucket         = var.backend_bucket
    key            = "${var.environment}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.backend_lock_table
    encrypt        = true
  }
}

