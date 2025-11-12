variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "db_subnet_ids" {
  type = list(string)
}
variable "db_sg_id" {
  type = string
}
variable "db_username" {
  type    = string
  default = "admin"
}
variable "db_password" {
  type    = string
  default = "YourPracticePassword123!"
}
variable "enable_multi_az" {
  type    = bool
  default = false
}
