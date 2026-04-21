###############################################################################
# Useful outputs for CI/CD workflows (Person D) and verification
###############################################################################

output "redis_hostname" {
  description = "Redis FQDN"
  value       = azurerm_redis_cache.this.hostname
}

output "redis_ssl_port" {
  description = "Redis SSL port"
  value       = azurerm_redis_cache.this.ssl_port
}

output "redis_primary_access_key" {
  description = "Redis primary access key"
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "namespace" {
  description = "K8s namespace where the app is deployed"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "deployment_name" {
  description = "K8s deployment name — Person D needs this for `kubectl set image`"
  value       = kubernetes_deployment.weather_app.metadata[0].name
}

output "service_name" {
  description = "K8s service name"
  value       = kubernetes_service.weather_app.metadata[0].name
}

output "container_name" {
  description = "Container name inside the pod — Person D needs this for `kubectl set image deployment/x container=image:tag`"
  value       = var.app_name
}
