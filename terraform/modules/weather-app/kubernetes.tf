###############################################################################
# Kubernetes resources
# The kubernetes provider is configured in the ROOT module and passed in.
# This module assumes the provider authenticates to the correct cluster
# (test cluster for env=test, prod cluster for env=prod).
###############################################################################

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.environment
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

###############################################################################
# Secrets — Redis connection details and the OpenWeather API key.
# In production you'd source these from Azure Key Vault via CSI driver, but
# raw K8s secrets are within scope for this assignment.
###############################################################################

resource "kubernetes_secret" "app_config" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    REDIS_HOST     = azurerm_redis_cache.this.hostname
    REDIS_PORT     = tostring(azurerm_redis_cache.this.ssl_port)
    REDIS_PASSWORD = azurerm_redis_cache.this.primary_access_key
    # Pre-built connection string in case the app expects one
    REDIS_URL       = "rediss://:${azurerm_redis_cache.this.primary_access_key}@${azurerm_redis_cache.this.hostname}:${azurerm_redis_cache.this.ssl_port}"
    WEATHER_API_KEY = var.weather_api_key
  }

  type = "Opaque"
}

###############################################################################
# Deployment
# Image is pulled from ACR using the AKS kubelet identity (AcrPull role
# granted by the ACR module). No imagePullSecrets needed.
###############################################################################

resource "kubernetes_deployment" "weather_app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = local.common_labels
      }

      spec {
        container {
          name              = var.app_name
          image             = "${var.acr_login_server}/${var.app_name}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          # Pull all env vars from the secret. Cleaner than per-key wiring.
          env_from {
            secret_ref {
              name = kubernetes_secret.app_config.metadata[0].name
            }
          }

          env {
            name  = "NODE_ENV"
            value = var.environment == "prod" ? "production" : "development"
          }

          env {
            name  = "PORT"
            value = "3000"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }

  # Make sure the secret exists before the pod tries to mount it
  depends_on = [
    kubernetes_secret.app_config,
    azurerm_redis_cache.this,
  ]

  # The deployment workflow (Person D) updates image tags via `kubectl set image`.
  # Ignore image changes on subsequent terraform applies so we don't fight CI/CD.
  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image,
      spec[0].replicas,
    ]
  }
}

###############################################################################
# Service — LoadBalancer type gives the app a public IP. Azure provisions
# a Standard Load Balancer automatically.
###############################################################################

resource "kubernetes_service" "weather_app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
