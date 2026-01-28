# Azure Container Registry Module

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Enable geo-replication for Premium SKU
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = var.tags
    }
  }

  # Network rules (Premium SKU only)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set_default_action != null ? [1] : []
    content {
      default_action = var.network_rule_set_default_action
    }
  }

  # Retention policy for untagged manifests (Premium SKU)
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      days    = var.retention_policy_days
      enabled = var.retention_policy_enabled
    }
  }

  tags = var.tags
}
