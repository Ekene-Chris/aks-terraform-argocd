environment            = "dev"
location               = "eastus"
resource_group_name    = "dev-aks-rg"
kubernetes_version     = "1.28.0"
admin_group_object_ids = ["your-azure-ad-group-id"]

# ArgoCD configuration
argocd_domain   = "argocd-dev.yourdomain.com"
github_org      = "your-org"
github_repo     = "your-repo"
target_revision = "main"
