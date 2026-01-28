output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet"
  value       = azurerm_subnet.aks.name
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = var.create_appgw_subnet ? azurerm_subnet.appgw[0].id : null
}

output "appgw_subnet_name" {
  description = "Name of the Application Gateway subnet"
  value       = var.create_appgw_subnet ? azurerm_subnet.appgw[0].name : null
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.aks.id
}
