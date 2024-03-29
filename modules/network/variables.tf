variable "identifier" {
  description = "Name of your network"
  type        = string
}

variable "blueprint" {
  description = "Name of the blueprint"
  type        = string
}

variable "vpc_ip_range" {
  description = "VPC ip range"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "region" {
  type        = string
  description = "Region for availability zones"
}