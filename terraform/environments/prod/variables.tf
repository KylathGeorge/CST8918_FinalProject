# --- Person B's original variables ---

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

# subnet_id is sourced from module.network_prod.prod_subnet_id — not an input variable

# --- Person C additions ---

variable "acr_name" {
  description = "Must match the acr_name in environments/test — prod looks it up via data source"
  type        = string
}

variable "name_suffix" {
  description = "Same suffix used in test. Example: grp9"
  type        = string
}

variable "weather_api_key" {
  description = "OpenWeather API key — set via TF_VAR_weather_api_key env var or GitHub Actions secret"
  type        = string
  sensitive   = true
}
