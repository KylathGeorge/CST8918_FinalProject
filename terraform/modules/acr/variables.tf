variable "acr_name" {
  description = "ACR name. Must be globally unique across Azure, 5–50 alphanumeric chars only (no hyphens). Example: cst8918grpNacr"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5–50 alphanumeric characters with no hyphens or special characters."
  }
}

variable "resource_group_name" {
  description = "Resource group from Person A's network module"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "canadacentral"
}

variable "sku" {
  description = "ACR SKU. Basic is fine for the project — cheapest, no geo-replication needed."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "aks_kubelet_principal_ids" {
  description = "List of kubelet identity object IDs from Person B's AKS module (test + prod). These get AcrPull."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
