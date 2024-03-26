variable "nodes_security_group_id" {
  description = "Security group id for nodes"
  type        = string
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  default     = true
}

variable "blueprint" {
  description = "Identifier of the blueprint"
  type        = string
}

variable "identifier" {
  default = "Identifier for load balancer"
  type    = string
}

variable "vpc_id" {
  description = "vpc id to pass in if block type is compute"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet ids to pass in if block type is compute"
  type        = list(string)
}

variable "bastion_node" {
  description = "The bastion node"
  type = object({
    id        = string
    slug      = string
    public_ip = string
  })
}

variable "bastion_ssh_port" {
  description = "The bastion ssh port"
  default     = 2348
}

variable "bootstrap_node" {
  description = "The bootstrap node"
  type = object({
    id        = string
    slug      = string
    public_ip = string
  })
}

variable "nodes" {
  description = "The nodes of the cluster"
  type = list(object({
    id        = string
    slug      = string
    public_ip = string
  }))
}