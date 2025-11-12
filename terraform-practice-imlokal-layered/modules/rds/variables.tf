variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {
  type = string
}

variable "enable_multi_az" {
  type    = bool
  default = false
}
