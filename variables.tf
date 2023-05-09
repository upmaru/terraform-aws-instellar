variable "region" {
  description = "The AWS region you want to use"
  default     = "us-west-2"
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "protect_leader" {
  type        = bool
  description = "Protect the database leader node"
  default     = true
}

variable "cluster_name" {
  description = "Name of your cluster"
  type        = string
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "bastion_size" {
  description = "Bastion instance type?"
  default     = "t2.micro"
}

variable "node_size" {
  description = "Which instance type?"
  default     = "t3.medium"
}

variable "vpc_ip_range" {
  description = "VPC ip range"
  default     = "10.0.0.0/16"
}

variable "storage_size" {
  description = "How much storage on your nodes?"
  default     = 40
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

variable "ssh_keys" {
  type        = list(string)
  description = "List of ssh key names"
  default     = []
}
