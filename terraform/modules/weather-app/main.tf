###############################################################################
# Weather App per-environment module
# Called once per environment (test, prod) from the root module.
# The kubernetes provider is passed in via provider aliases — see examples/root.
#
# Creates:
#   - Azure Cache for Redis (this env)
#   - K8s namespace
#   - K8s secret (Redis credentials)
#   - K8s deployment (Remix Weather App)
#   - K8s service (LoadBalancer, exposes app on public IP)
###############################################################################

locals {
  # consistent naming — matches the resource group convention from Person A
  name_prefix = "${var.app_name}-${var.environment}"

  common_labels = {
    app         = var.app_name
    environment = var.environment
    managed-by  = "terraform"
  }
}
