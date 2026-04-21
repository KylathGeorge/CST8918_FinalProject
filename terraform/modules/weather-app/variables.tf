###############################################################################
# Required inputs
###############################################################################

variable "environment" {
  description = "Environment name. Used for namespace, naming, and NODE_ENV."
  type        = string

  validation {
    condition     = contains(["test", "prod", "dev"], var.environment)
    error_message = "Environment must be one of: test, prod, dev."
  }
}

variable "resource_group_name" {
  description = "Resource group from Person A's network module"
  type        = string
}

variable "location" {
  description = "Azure region for the Redis cache"
  type        = string
  default     = "canadacentral"
}

variable "name_suffix" {
  description = "Globally-unique suffix for Redis name (e.g. group number). Redis names must be globally unique."
  type        = string
}

variable "acr_login_server" {
  description = "ACR FQDN — output from the acr module (e.g. cst8918grpNacr.azurecr.io)"
  type        = string
}

variable "weather_api_key" {
  description = "OpenWeather API key. Pass via TF_VAR_weather_api_key or GitHub Actions secret."
  type        = string
  sensitive   = true
}

###############################################################################
# Application config
###############################################################################

variable "app_name" {
  description = "App name — used for K8s deployment, service, and image name"
  type        = string
  default     = "weather-app"
}

variable "image_tag" {
  description = "Initial image tag. CI/CD will overwrite with commit SHA on deploys (lifecycle ignores changes)."
  type        = string
  default     = "latest"
}

variable "replica_count" {
  description = "Pod replicas. Default 1 for test, override to 2+ for prod."
  type        = number
  default     = 1
}

###############################################################################
# Redis sizing
###############################################################################

variable "redis_capacity" {
  description = "Redis capacity. Basic: 0=250MB, 1=1GB, 2=2.5GB. Default 0 = cheapest."
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "Redis family. C = Basic/Standard, P = Premium."
  type        = string
  default     = "C"
}

variable "redis_sku" {
  description = "Redis SKU."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku)
    error_message = "Redis SKU must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
