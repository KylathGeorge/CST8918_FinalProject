###############################################################################
# Azure Cache for Redis
# Basic C0 = ~$22 CAD/month. Cheapest tier, single node, no SLA — fine for a
# graded project. Bump to Standard if you want replication.
###############################################################################

resource "azurerm_redis_cache" "this" {
  name                = "${local.name_prefix}-redis-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  capacity = var.redis_capacity # 0 = 250MB (C0)
  family   = var.redis_family   # C = Basic/Standard
  sku_name = var.redis_sku      # Basic

  non_ssl_port_enabled = false # force TLS
  minimum_tls_version  = "1.2"

  redis_configuration {
    # Defaults are sane for Basic. No persistence on Basic SKU.
  }

  tags = merge(var.tags, local.common_labels)
}
