variable "resource_group_name" {
  type        = string
  description = "The name of the backend resource group."
}

variable "location" {
  type        = string
  default     = "Canada Central"
}

variable "group_number" {
  type        = string
  description = "Group number for naming uniqueness."
}