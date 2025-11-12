variable "vpc_id" {
  type        = string
  description = "VPC id to create security groups in"
}

variable "bastion_allowed_ip" {
  type        = string
  description = "Your public IP/CIDR for bastion SSH access (e.g. 1.2.3.4/32)"
  default     = "175.101.67.131/32"
}

variable "open_ssh_to_world" {
  type        = bool
  description = "If true, add ingress rule for 0.0.0.0/0 on port 22 (insecure - practice only)"
  default     = true
}
