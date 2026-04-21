# --- Person A fills these in ---
resource_group_name = "cst8918-final-project-group-5"
subnet_id           = "10.1.0.0/16"
location            = "canadacentral"

# --- Person C fills these in ---
acr_name    = "cst8918grp5acr" # example: cst8918grp9acr (no hyphens, alphanumeric only)
name_suffix = "grp5"           # example: grp9

# prod_kubelet_identity_object_id = "" # fill in after first prod apply

# weather_api_key is set via environment variable: export TF_VAR_weather_api_key="your-key"
# Do NOT commit the real key here
