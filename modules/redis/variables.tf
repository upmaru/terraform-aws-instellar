variable "identifier" {
  description = "Identifier of the cluster"
  type        = string
}

variable "description" {
  description = "Description of the cache cluster"
  type        = string
}

variable "engine_version" {
  description = "The version number of Redis to be used"
  default     = "7.0"
}

variable "blueprint" {
  description = "Blueprint name"
  type        = string
}

variable "num_cache_clusters" {
  description = "Number of cache replicas"
  default     = 1
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes"
  default     = "cache.t3.micro"
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "port" {
  description = "The port on which the cache accepts connections"
  default     = 6379
  type        = number
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "at_rest_encryption" {
  description = "Enable / Disable at rest encryption"
  default     = true
}

variable "transit_encryption" {
  description = "Enable / Disable transit encryption"
  default     = true
}

variable "manage_auth_token" {
  description = "Enable / Disable auth token management with secret manager"
  default     = false
}

variable "password_revision" {
  description = "Password revision"
  default     = 1
  type        = number
}

variable "nodes_iam_role" {
  description = "The IAM role to attach the policy to"
  type = object({
    name = string
    id   = string
  })
}