# --- Person B's original variables ---

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

# subnet_id is sourced from module.network_test.test_subnet_id — not an input variable

# --- Person C additions ---

variable "acr_name" {
  description = "ACR name — globally unique, alphanumeric only, 5-50 chars. Example: cst8918grp9acr"
  type        = string
}

variable "name_suffix" {
  description = "Short globally-unique suffix for Redis name. Use your group number. Example: grp9"
  type        = string
}

variable "weather_api_key" {
  description = "OpenWeather API key — set via TF_VAR_weather_api_key env var or GitHub Actions secret"
  type        = string
  sensitive   = true
}

variable "prod_kubelet_identity_object_id" {
  description = "Kubelet identity from prod AKS cluster — needed so prod cluster can pull from ACR. Run prod apply first, paste the output here."
  type        = string
  default     = "" # update after first prod apply
}
