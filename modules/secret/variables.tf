variable "key" {
  description = "Key for the secret"
  type        = string
}

variable "blueprint" {
  description = "Identifier of the blueprint"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
}

variable "value" {
  description = "The value of the secret"
  type        = string
}

variable "nodes_iam_roles" {
  description = "The IAM roles to attach the policy to"
  type = list(
    object({
      name = string
      id   = string
    })
  )
}
