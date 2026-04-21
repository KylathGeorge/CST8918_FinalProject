variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the managed identity will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "role_scope" {
  description = "Azure scope for the role assignment"
  type        = string
}

variable "role_definition_name" {
  description = "Azure role to assign"
  type        = string
  default     = "Contributor"
}

variable "github_subject" {
  description = "GitHub OIDC subject claim to trust"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the identity"
  type        = map(string)
  default     = {}
}