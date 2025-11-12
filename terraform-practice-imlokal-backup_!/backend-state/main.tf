terraform {
required_providers {
aws = { source = "hashicorp/aws" }
}
backend "local" {}
}


provider "aws" {
region = "ap-south-1"
}


resource "aws_s3_bucket" "tf_state" {
bucket = "practice-terraform-state-imlokal-12345" # CHANGE to globally unique name if collision
acl = "private"
versioning { enabled = true }
server_side_encryption_configuration {
rule {
apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
}
}
tags = { Name = "practice-terraform-state" }
}


resource "aws_dynamodb_table" "tf_lock" {
name = "practice-terraform-locks"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"
attribute { name = "LockID"; type = "S" }
tags = { Name = "practice-terraform-locks" }
}


output "backend_bucket" { value = aws_s3_bucket.tf_state.bucket }
output "dynamodb_table" { value = aws_dynamodb_table.tf_lock.name }