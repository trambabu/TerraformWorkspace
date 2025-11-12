terraform {
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

locals {
  envs = ["dev", "staging", "prod"]
}

resource "aws_s3_bucket" "state" {
  for_each = toset(local.envs)
  bucket   = "tf-state-${each.key}-${var.account_id}"
  force_destroy = true

  tags = {
    Name = "tf-state-${each.key}"
    Environment = each.key
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.state
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "lock" {
  for_each = toset(local.envs)
  name         = "tf-lock-${each.key}"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  tags = {
    Name = "tf-lock-${each.key}"
    Environment = each.key
  }
}

output "s3_buckets" {
  value = { for k, v in aws_s3_bucket.state : k => v.bucket }
}

output "dynamodb_tables" {
  value = { for k, v in aws_dynamodb_table.lock : k => v.name }
}
