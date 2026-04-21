output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server host"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

###############################################################################
# Structured kube_config object — used by the kubernetes provider in each
# environment's main.tf. Fields are base64-encoded exactly as AKS returns them.
###############################################################################

output "kube_config" {
  description = "Structured kube config object for use with the kubernetes provider"
  sensitive   = true
  value = {
    host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.this.kube_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
    username               = azurerm_kubernetes_cluster.this.kube_config[0].username
    password               = azurerm_kubernetes_cluster.this.kube_config[0].password
  }
}

###############################################################################
# Kubelet identity — needed so each environment's ACR module can grant AcrPull
# to the cluster. AKS auto-creates this when identity type = SystemAssigned.
###############################################################################

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity — grant AcrPull to this ID"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}