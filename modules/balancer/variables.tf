variable "nodes_security_group_id" {
  description = "Security group id for nodes"
  type        = string
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  default     = true
}

variable "identifier" {
  default = "identifier for load balancer"
  type    = string
}