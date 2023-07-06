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
  sensitive   = true
}

variable "identifier" {
  description = "Database instance name"
  type        = string
}

variable "db_name" {
  description = "Database name to create"
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
  type        = string
  default     = "instellar"
}

variable "storage_size" {
  description = "Database storage size"
  default     = 20
}

variable "max_storage_size" {
  description = "Database max storage size"
  default     = 100
}

variable "publically_accessible" {
  description = "Database publically accessible"
  type        = bool
  default     = false
}

