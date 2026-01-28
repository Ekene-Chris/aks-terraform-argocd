output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "external_secrets_identity_id" {
  description = "ID of the External Secrets user-assigned identity"
  value       = azurerm_user_assigned_identity.external_secrets.id
}

output "external_secrets_identity_client_id" {
  description = "Client ID of the External Secrets identity"
  value       = azurerm_user_assigned_identity.external_secrets.client_id
}

output "external_secrets_identity_principal_id" {
  description = "Principal ID of the External Secrets identity"
  value       = azurerm_user_assigned_identity.external_secrets.principal_id
}

output "tenant_id" {
  description = "Tenant ID of the Key Vault"
  value       = azurerm_key_vault.main.tenant_id
}
