provider "aws" {
  region = "ap-south-1"
}

# S3 Buckets to delete
resource "aws_s3_bucket" "cleanup" {
  for_each = toset([
    "imlokal-tfstate-unique",
    "tf-state-dev-188939218963",
    "tf-state-prod-188939218963",
    "tf-state-staging-188939218963",
    "tram-state-bucket-dev-123456"
  ])
  bucket = each.key

  # Force deletion of all objects
  force_destroy = true
}

# DynamoDB tables to delete (example: Terraform backend locks)
resource "aws_dynamodb_table" "cleanup" {
  for_each = toset([
    "tf-backend-lock",  # Replace with actual table names if different
  ])
  name         = each.key
  billing_mode = "PAY_PER_REQUEST"

  lifecycle {
    prevent_destroy = false
  }
}
