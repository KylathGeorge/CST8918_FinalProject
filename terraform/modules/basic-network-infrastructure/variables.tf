variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  type        = string
  default     = "Canada Central"
}

variable "tags" {
  type    = map(string)
  default = {}
}