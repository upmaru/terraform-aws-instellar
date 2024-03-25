variable "identifier" {
  description = "Identifier of the secret"
  type = string
}

variable "blueprint" {
  description = "Identifier of the blueprint"
  type = string
}

variable "description" {
  description = "Description of the secret"
  type = string
}

variable "secret_value" {
  description = "The value of the secret"
  type = string
}

variable "nodes_iam_role" {
  description = "The IAM role to attach the policy to"
  type = object({
    name = string
    id = string
  })
}
