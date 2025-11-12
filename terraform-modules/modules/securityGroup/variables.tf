variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "security_group_name" {
    description = "The name of the security group"
    type        = string
}

variable "security_group_description" {
    description = "The description of the security group"
    type        = string
}

variable "tags" {
    description = "A map of tags to assign to the security group"
    type        = map(string)
}
variable "ingress_ports" {
  description = "List of inbound ports to allow"
  type        = list(number)
  default     = [22] # default allow SSH
}