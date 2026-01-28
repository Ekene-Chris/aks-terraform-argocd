variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "sku" {
  description = "SKU of the ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the ACR"
  type        = bool
  default     = false
}

variable "georeplications" {
  description = "List of geo-replication locations (Premium SKU only)"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
  }))
  default = []
}

variable "network_rule_set_default_action" {
  description = "Default action for network rules (Allow or Deny)"
  type        = string
  default     = null
}

variable "retention_policy_days" {
  description = "Number of days to retain untagged manifests"
  type        = number
  default     = 7
}

variable "retention_policy_enabled" {
  description = "Enable retention policy for untagged manifests"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
