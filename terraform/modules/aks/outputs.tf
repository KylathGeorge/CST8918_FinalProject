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

output "kubelet_identity_object_id" {
  description = "Kubelet managed identity object ID — needed for AcrPull role assignment so AKS can pull from ACR"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "kube_config" {
  description = "Full kube_config block — needed by Kubernetes provider in environment configs"
  value       = azurerm_kubernetes_cluster.this.kube_config[0]
  sensitive   = true
}