variable "aws_region" { type = string; default = "ap-south-1" }
variable "state_bucket_name" { type = string; default = "practice-terraform-state-imlokal-12345" }
variable "dynamodb_table_name" { type = string; default = "practice-terraform-locks" }
#variable "state_file_key" { type = string; default = "global/s3/terraform.tfstate" }