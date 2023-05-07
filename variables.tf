variable "region" {
  description = "The AWS region you want to use"
  default     = "us-west-2"
}

# variable "access_key" {
#   description = "AWS Access Key"
# }

# variable "secret_key" {
#   description = "AWS Secret Key"
# }

variable "cluster_name" {
  description = "Name of your cluster"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
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

variable "cluster_size" {
  description = "How many nodes do you want in your cluster?"
  default     = 0
}

variable "ssh_keys" {
  type        = list(string)
  description = "List of ssh key names"
  default     = []
}
