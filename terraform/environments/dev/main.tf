terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatedevaks"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Configure Helm provider after AKS is created
provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.host
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
    token                  = module.aks.kube_config.token
  }
}

# Configure Kubernetes provider after AKS is created
provider "kubernetes" {
  host                   = module.aks.kube_config.host
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  token                  = module.aks.kube_config.token
}

# Resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Networking
module "networking" {
  source = "../../modules/networking"

  vnet_name           = "${var.environment}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_address_space          = ["10.0.0.0/16"]
  aks_subnet_address_prefix   = ["10.0.1.0/24"]
  appgw_subnet_address_prefix = ["10.0.2.0/24"]

  tags = local.common_tags
}

# Container Registry
module "acr" {
  source = "../../modules/acr"

  acr_name            = replace("${var.environment}aksacr${random_string.suffix.result}", "-", "")
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = local.common_tags
}

# AKS Cluster
module "aks" {
  source = "../../modules/aks"

  cluster_name        = "${var.environment}-aks-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.environment}-aks"
  kubernetes_version  = var.kubernetes_version
  environment         = var.environment

  subnet_id = module.networking.aks_subnet_id

  system_node_pool_vm_size   = "Standard_D2s_v3"
  system_node_pool_min_count = 1
  system_node_pool_max_count = 3

  user_node_pool_vm_size   = "Standard_D4s_v3"
  user_node_pool_min_count = 2
  user_node_pool_max_count = 10

  admin_group_object_ids = var.admin_group_object_ids

  tags = local.common_tags
}

# Key Vault for secrets
module "key_vault" {
  source = "../../modules/key-vault"

  key_vault_name      = "${var.environment}akskv${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  oidc_issuer_url  = module.aks.oidc_issuer_url
  admin_object_ids = var.admin_group_object_ids

  allowed_subnet_ids = [module.networking.aks_subnet_id]

  tags = local.common_tags

  depends_on = [module.aks]
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

# Bootstrap ArgoCD
module "argocd_bootstrap" {
  source = "../../modules/argocd-bootstrap"

  argocd_domain         = var.argocd_domain
  github_org            = var.github_org
  github_repo           = var.github_repo
  environment           = var.environment
  target_revision       = var.target_revision
  admin_group_object_id = length(var.admin_group_object_ids) > 0 ? var.admin_group_object_ids[0] : ""

  depends_on = [module.aks]
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps-Demo"
  }
}
