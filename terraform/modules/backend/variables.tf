variable "resource_group_name" {
  type        = string
  description = "The name of the backend resource group."
}

variable "location" {
  type    = string
  default = "South Africa North"
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}

variable "group_number" {
  type        = string
  description = "Group number for naming uniqueness."
}