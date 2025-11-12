variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "state_bucket_name" {
  type    = string
  default = "imlokal-tfstate-unique"
}
variable "dynamodb_table_name" {
  type    = string
  default = "imlokal-tf-locks"
}
