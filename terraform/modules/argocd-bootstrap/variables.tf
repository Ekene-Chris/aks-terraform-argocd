variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.51.6"
}

variable "argocd_domain" {
  description = "Domain for ArgoCD server"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "target_revision" {
  description = "Git branch or tag for ArgoCD to sync"
  type        = string
  default     = "main"
}

variable "admin_group_object_id" {
  description = "Azure AD group object ID for admin access"
  type        = string
  default     = ""
}

variable "server_insecure" {
  description = "Run ArgoCD server in insecure mode (disable TLS)"
  type        = bool
  default     = true
}

variable "admin_enabled" {
  description = "Enable ArgoCD admin user"
  type        = bool
  default     = true
}

variable "server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 2
}

variable "controller_replicas" {
  description = "Number of ArgoCD controller replicas"
  type        = number
  default     = 1
}

variable "repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 2
}

variable "ingress_enabled" {
  description = "Enable ingress for ArgoCD"
  type        = bool
  default     = true
}

variable "service_type" {
  description = "Service type for ArgoCD server"
  type        = string
  default     = "ClusterIP"
}

variable "enable_metrics" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = true
}

variable "notifications_enabled" {
  description = "Enable ArgoCD notifications"
  type        = bool
  default     = false
}
