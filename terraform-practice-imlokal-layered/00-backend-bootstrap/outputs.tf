output "backend_bucket" {
  value = aws_s3_bucket.backend.bucket
}

output "backend_lock_table" {
  value = aws_dynamodb_table.terraform_locks.name
}
