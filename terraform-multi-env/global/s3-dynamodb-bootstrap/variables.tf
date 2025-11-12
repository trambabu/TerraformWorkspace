variable "aws_region" {
  default = "ap-south-1"
}

variable "account_id" {
  description = "AWS account ID to ensure unique S3 names"
  type        = string
}
