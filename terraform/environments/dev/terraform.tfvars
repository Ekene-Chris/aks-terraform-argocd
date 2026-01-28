subscription_id        = "60f5b479-ab51-4fc7-a776-1acf71470cc6"
environment            = "dev"
location               = "eastus"
resource_group_name    = "dev-aks-rg"
kubernetes_version     = "1.34.0"
admin_group_object_ids = ["6c684ab2-10a1-454f-a7cb-cca90f62f49a"]

# ArgoCD configuration
argocd_domain   = "argocd.ekenechris.com"
github_org      = "Ekene-Chris"
github_repo     = "aks-terraform-argocd"
target_revision = "main"

# Two-phase deployment: Set to true after AKS is created
enable_argocd_bootstrap = true
