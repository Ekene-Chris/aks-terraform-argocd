variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "subnet_id" {
  description = "ID of the subnet for the AKS nodes"
  type        = string
}

# System node pool configuration
variable "system_node_pool_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "system_node_pool_min_count" {
  description = "Minimum number of nodes in system pool"
  type        = number
  default     = 1
}

variable "system_node_pool_max_count" {
  description = "Maximum number of nodes in system pool"
  type        = number
  default     = 3
}

variable "system_node_pool_os_disk_size_gb" {
  description = "OS disk size for system nodes"
  type        = number
  default     = 128
}

# User node pool configuration
variable "user_node_pool_vm_size" {
  description = "VM size for user node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_pool_min_count" {
  description = "Minimum number of nodes in user pool"
  type        = number
  default     = 2
}

variable "user_node_pool_max_count" {
  description = "Maximum number of nodes in user pool"
  type        = number
  default     = 10
}

variable "user_node_pool_os_disk_size_gb" {
  description = "OS disk size for user nodes"
  type        = number
  default     = 128
}

variable "user_node_pool_taints" {
  description = "Taints for user node pool"
  type        = list(string)
  default     = []
}

# Network configuration
variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "10.1.0.10"
}

# Azure AD configuration
variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

# Feature flags
variable "azure_policy_enabled" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "automatic_channel_upgrade" {
  description = "Automatic upgrade channel (none, patch, rapid, stable, node-image)"
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["none", "patch", "rapid", "stable", "node-image"], var.automatic_channel_upgrade)
    error_message = "Upgrade channel must be none, patch, rapid, stable, or node-image."
  }
}

variable "sku_tier" {
  description = "SKU tier for the AKS cluster (Free or Standard)"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be Free or Standard."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
