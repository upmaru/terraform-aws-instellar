variable "protect_leader" {
  type        = bool
  description = "Protect the database leader node"
  default     = true
}

variable "blueprint" {
  description = "Identifier of the blueprint"
  type        = string
}

variable "identifier" {
  description = "Name of your cluster"
  type        = string
}

variable "balancer" {
  description = "Enable Load Balancer"
  default     = false
}

variable "balancer_deletion_protection" {
  description = "Enable balancer deletion protection"
  default     = true
}

variable "publicly_accessible" {
  description = "Make the cluster publically accessible? If you use a load balancer this can be false."
  default     = true
}

variable "ssm" {
  description = "Enable SSM"
  default     = false
}

variable "vpc_ip_range" {
  description = "VPC ip range"
  type        = string
}

variable "network_dependencies" {
  description = "value"
  default     = []
}

variable "vpc_id" {
  description = "vpc id to pass in if block type is compute"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet ids to pass in if block type is compute"
  type        = list(string)
}

variable "bastion_size" {
  description = "Bastion instance type?"
  default     = "t3a.micro"
}

variable "bastion_ssh" {
  description = "Enable SSH port"
  default     = true
}

variable "balancer_ssh" {
  description = "Enable SSH port on balancer"
  default     = true
}

variable "node_size" {
  description = "Which instance type?"
  default     = "t3a.medium"
}

variable "node_monitoring" {
  description = "Enable / Disable detailed monitoring"
  default     = false
}

variable "storage_size" {
  description = "How much storage on your nodes?"
  default     = 40
}

variable "volume_type" {
  description = "Type of EBS Volume to use"
  default     = "gp3"
}

variable "cluster_topology" {
  type = list(object({
    id   = number
    name = string
    size = optional(string, "t3.medium")
  }))
  description = "How many nodes do you want in your cluster?"
  default     = []
}

variable "node_detail_revision" {
  description = "Revision of the node detail"
  default     = 1
}

variable "ssh_keys" {
  type        = list(string)
  description = "List of ssh key names"
  default     = []
}
