# Azure Kubernetes Service (AKS) Module

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Enable Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # System node pool (required)
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool_vm_size
    auto_scaling_enabled         = true
    min_count                    = var.system_node_pool_min_count
    max_count                    = var.system_node_pool_max_count
    vnet_subnet_id               = var.subnet_id
    only_critical_addons_enabled = true
    os_disk_size_gb              = var.system_node_pool_os_disk_size_gb
    os_disk_type                 = "Managed"
    temporary_name_for_rotation  = "systemtemp"

    upgrade_settings {
      max_surge = "33%"
    }

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    tags = var.tags
  }

  # Identity configuration - using SystemAssigned
  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Azure AD integration with Azure RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  # Key Vault secrets provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Auto-upgrade configuration
  automatic_upgrade_channel = var.automatic_channel_upgrade

  # SKU tier
  sku_tier = var.sku_tier

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

# User node pool for application workloads
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_node_pool_vm_size
  auto_scaling_enabled  = true
  min_count             = var.user_node_pool_min_count
  max_count             = var.user_node_pool_max_count
  vnet_subnet_id        = var.subnet_id
  os_disk_size_gb       = var.user_node_pool_os_disk_size_gb
  os_disk_type          = "Managed"
  mode                  = "User"

  upgrade_settings {
    max_surge = "33%"
  }

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = "applications"
  }

  node_taints = var.user_node_pool_taints

  tags = var.tags

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

# Role assignment for AKS cluster to manage network resources
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

# Grant admin groups cluster admin access via Azure RBAC
resource "azurerm_role_assignment" "aks_cluster_admin" {
  for_each             = toset(var.admin_group_object_ids)
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}
