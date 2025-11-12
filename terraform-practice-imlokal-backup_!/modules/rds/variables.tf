variable "db_username" {
  type        = string
  description = "DB admin user"
  default     = "tfadmin"
}

variable "db_password" {
  type        = string
  description = "DB password (practice: in tfvars)"
  sensitive   = true
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Subnet ids for RDS DB subnet group"
}

variable "db_sg_id" {
  type        = string
  description = "Security group for DB access"
}

variable "enable_multi_az" {
  type        = bool
  description = "If true, enable multi_az RDS (not free-tier)"
  default     = false
}
