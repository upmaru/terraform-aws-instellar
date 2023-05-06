variable "region" {
  description = "The AWS region you want to use"
  default = "us-east-1"
}

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "cluster_name" {
  description = "Name of your cluster"
}

variable "vpc_ip_range" {
  description = "VPC ip range"
  default = "10.0.0.0/16"
}
