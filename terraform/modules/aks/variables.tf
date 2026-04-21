variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.32"
}

variable "node_count" {
  description = "Node count for non-autoscaling clusters"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum node count when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum node count when autoscaling is enabled"
  type        = number
  default     = 3
}

variable "subnet_id" {
  description = "Subnet ID for the AKS nodes"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the AKS cluster"
  type        = map(string)
  default     = {}
}
