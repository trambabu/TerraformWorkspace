variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "domain_name" {
  type    = string
  default = "imlokal.in"
}
variable "alb_dns_name" {
  type    = string
  default = ""
}
variable "alb_zone_id" {
  type    = string
  default = ""
}
