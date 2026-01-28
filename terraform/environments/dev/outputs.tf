output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "acr_login_server" {
  description = "Login server URL for the ACR"
  value       = module.acr.acr_login_server
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "argocd_server_url" {
  description = "URL for ArgoCD server"
  value       = var.enable_argocd_bootstrap ? module.argocd_bootstrap[0].argocd_server_url : null
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity"
  value       = module.aks.oidc_issuer_url
}

output "external_secrets_client_id" {
  description = "Client ID for External Secrets workload identity"
  value       = module.key_vault.external_secrets_identity_client_id
}

# Command to get AKS credentials
output "get_credentials_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}
