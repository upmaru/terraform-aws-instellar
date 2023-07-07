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

variable "identifier" {
  description = "Database instance name"
  type        = string
}

variable "db_name" {
  description = "Database name to create"
  default     = "instellar"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_username" {
  description = "Database username"
  default     = "instellar"
  type        = string
}

variable "storage_size" {
  description = "Database storage size"
  default     = 20
  type        = number
}

variable "max_storage_size" {
  description = "Database max storage size"
  default     = 100
  type        = number
}

variable "storage_type" {
  description = "Database storage type"
  default     = "gp3"
  type        = string
}

variable "publically_accessible" {
  description = "Database publically accessible"
  default     = false
  type        = bool
}

variable "deletion_protection" {
  description = "Database deletion protection"
  default     = true
  type        = bool
}

variable "security_group_ids" {
  description = "Database security group ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "Database VPC id"
  type        = string
}
