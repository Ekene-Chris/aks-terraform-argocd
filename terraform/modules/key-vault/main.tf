# Azure Key Vault Module for Secrets Management

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  # Enable RBAC authorization (recommended for AKS Workload Identity)
  enable_rbac_authorization = true

  # Network access configuration
  network_acls {
    default_action             = var.network_acls_default_action
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# User-assigned Managed Identity for External Secrets Operator
resource "azurerm_user_assigned_identity" "external_secrets" {
  name                = "${var.key_vault_name}-external-secrets-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Role assignment for External Secrets identity to read secrets
resource "azurerm_role_assignment" "external_secrets_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.external_secrets.principal_id
}

# Federated Identity Credential for Workload Identity
resource "azurerm_federated_identity_credential" "external_secrets" {
  count               = var.enable_workload_identity ? 1 : 0
  name                = "external-secrets-federation"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.external_secrets.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:external-secrets-system:external-secrets-sa"
}

# Optional: Role assignment for admin access
resource "azurerm_role_assignment" "admin_access" {
  for_each             = toset(var.admin_object_ids)
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}
