variable "blueprint" {
  description = "Identifier of the blueprint"
  type        = string
}

variable "identifier" {
  description = "Identiifer for global accelerator"
  type        = string
}

variable "region" {
  description = "Region for endpoint group"
  type        = string
}

variable "balancer" {
  type = object({
    enabled = bool
    id      = optional(string)
  })
}

variable "nodes_security_group_id" {
  description = "Security group id for nodes"
  type        = string
}

variable "node_ids" {
  type = list(string)
}