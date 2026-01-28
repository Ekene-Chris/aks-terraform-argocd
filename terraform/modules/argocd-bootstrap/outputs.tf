output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_url" {
  description = "URL for ArgoCD server"
  value       = "https://${var.argocd_domain}"
}

output "helm_release_name" {
  description = "Name of the ArgoCD Helm release"
  value       = helm_release.argocd.name
}

output "helm_release_version" {
  description = "Version of the ArgoCD Helm chart"
  value       = helm_release.argocd.version
}
