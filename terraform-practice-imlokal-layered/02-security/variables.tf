variable "project_name" {
  type = string
}

variable "bastion_allowed_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "open_ssh_to_world" {
  type    = bool
  default = false
}

variable "aws_region" {
  type = string
}

variable "backend_bucket" {
  type = string
}

variable "backend_lock_table" {
  type = string
}
