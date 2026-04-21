# --- Person A fills these in ---
resource_group_name = "REPLACE_WITH_RESOURCE_GROUP_NAME"
subnet_id           = "REPLACE_WITH_PROD_SUBNET_ID"
location            = "canadacentral"

# --- Person C fills these in (must match test) ---
acr_name    = "REPLACE_WITH_ACR_NAME"       # same value as in test/terraform.tfvars
name_suffix = "REPLACE_WITH_GROUP_NUMBER"   # same value as in test/terraform.tfvars

# weather_api_key is set via environment variable: export TF_VAR_weather_api_key="your-key"
