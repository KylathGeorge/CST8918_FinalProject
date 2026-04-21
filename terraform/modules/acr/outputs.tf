output "acr_id" {
  description = "ACR resource ID"
  value       = azurerm_container_registry.this.id
}

output "acr_login_server" {
  description = "ACR login server FQDN — used as image registry prefix in K8s deployment"
  value       = azurerm_container_registry.this.login_server
}

output "acr_name" {
  description = "ACR name — used by Docker build workflow (Person D) for `az acr login`"
  value       = azurerm_container_registry.this.name
}
