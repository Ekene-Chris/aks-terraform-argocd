variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.28.0"
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

variable "argocd_domain" {
  description = "Domain for ArgoCD server"
  type        = string
  default     = "argocd-dev.yourdomain.com"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "your-org"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "your-repo"
}

variable "target_revision" {
  description = "Git branch or tag for ArgoCD to sync"
  type        = string
  default     = "main"
}

variable "enable_argocd_bootstrap" {
  description = "Enable ArgoCD bootstrap (set to true after AKS is created)"
  type        = bool
  default     = false
}
