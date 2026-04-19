variable "group_number" {
  type        = string
  description = "The group number (e.g., 5) used for naming"
}

variable "location" {
  type        = string
  default     = "Canada Central"
}

variable "tags" {
  type    = map(string)
  default = {}
}