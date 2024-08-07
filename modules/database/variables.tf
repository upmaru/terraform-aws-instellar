variable "identifier" {
  description = "Database instance name"
  type        = string
}

variable "blueprint" {
  description = "Blueprint name"
  type        = string
}

variable "region" {
  description = "Database region"
  type        = string
}

variable "db_size" {
  description = "Database instance size"
  type        = string
}

variable "db_name" {
  description = "Database name to create"
  default     = "instellar"
  type        = string
}

variable "port" {
  description = "Database port"
  type        = number
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "ca_cert_identifier" {
  description = "CA Cert identifier"
  default     = "rds-ca-rsa2048-g1"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_password_revision" {
  description = "Database password revision"
  default     = 1
  type        = number
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

variable "enable_performance_insight" {
  description = "Enable performance insight"
  default     = false
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

variable "publicly_accessible" {
  description = "Database publicly accessible"
  default     = false
  type        = bool
}

variable "deletion_protection" {
  description = "Database deletion protection"
  default     = true
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Database skip final snapshot"
  default     = false
  type        = bool
}

variable "nodes_iam_roles" {
  description = "The IAM role to attach the policy to"
  type = list(
    object({
      name = string
      id   = string
    })
  )
}

variable "backup_window" {
  description = "Database backup window, do not overlap with maintenance_window"
  default     = "09:46-10:16"
}

variable "maintenance_window" {
  description = "Database maintenance window"
  default     = "Sun:00:00-Sun:03:00"
}

variable "subnet_ids" {
  description = "Database subnet ids"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Database security group ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "Database VPC id"
  type        = string
}

variable "backup_retention_period" {
  description = "Backup retention days"
  default     = 5
  type        = number
}

variable "manage_master_user_password" {
  description = "Manage master user password"
  default     = false
  type        = bool
}

variable "multi_az" {
  description = "Enable multi AZ"
  default     = false
  type        = bool
}

variable "availability_zone" {
  description = "Database availability zone"
  type        = string
  default     = null
}

variable "replicate_source_db" {
  description = "Replicate source database"
  type        = string
  default     = null
}

variable "manage_credential_with_secret" {
  description = "Manage credentials with secret"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}