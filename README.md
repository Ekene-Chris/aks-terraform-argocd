# AKS Terraform ArgoCD Starter

Production-ready Azure Kubernetes Service (AKS) setup with Terraform and ArgoCD implementing GitOps.

## Architecture

This project separates concerns into two distinct layers:

- **Infrastructure Layer (Terraform)**: AKS cluster, networking, node pools, container registry, Key Vault, and identity management
- **Application Layer (ArgoCD)**: Workloads, services, and application configurations managed via GitOps

## Prerequisites

- Active Azure subscription
- Azure CLI installed and configured
- Terraform >= 1.5.0
- kubectl
- Service Principal with Contributor access

## Project Structure

```
├── terraform/
│   ├── modules/
│   │   ├── networking/      # VNet and subnet configuration
│   │   ├── acr/             # Azure Container Registry
│   │   ├── aks/             # AKS cluster configuration
│   │   ├── key-vault/       # Azure Key Vault for secrets
│   │   └── argocd-bootstrap/# ArgoCD installation via Helm
│   └── environments/
│       └── dev/             # Dev environment configuration
└── kubernetes/
    ├── bootstrap/
    │   └── dev/             # ArgoCD App of Apps configuration
    ├── infrastructure/
    │   ├── cert-manager/    # SSL certificate management
    │   ├── nginx-ingress/   # Ingress controller
    │   └── external-secrets/# External Secrets Operator
    └── applications/
        └── dev/
            └── myapp/       # Sample application
```

## Quick Start

### 1. Configure Azure Backend

Create a storage account for Terraform state:

```bash
# Create resource group for state
az group create --name terraform-state-rg --location eastus

# Create storage account
az storage account create \
  --name tfstatedevaks \
  --resource-group terraform-state-rg \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name tfstatedevaks
```

### 2. Update Configuration

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
environment            = "dev"
location               = "eastus"
resource_group_name    = "dev-aks-rg"
kubernetes_version     = "1.28.0"
admin_group_object_ids = ["your-azure-ad-group-id"]

argocd_domain   = "argocd-dev.yourdomain.com"
github_org      = "your-org"
github_repo     = "your-repo"
target_revision = "main"
```

### 3. Deploy Infrastructure

```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply
terraform apply
```

### 4. Access the Cluster

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group dev-aks-rg \
  --name dev-aks-cluster

# Verify
kubectl get nodes
```

### 5. Access ArgoCD

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open https://localhost:8080 and login with username `admin`.

## Components

### Infrastructure (Terraform)

| Module           | Description                                 |
| ---------------- | ------------------------------------------- |
| networking       | VNet, subnets, NSG                          |
| acr              | Azure Container Registry                    |
| aks              | AKS cluster with system and user node pools |
| key-vault        | Azure Key Vault with Workload Identity      |
| argocd-bootstrap | ArgoCD installation and root application    |

### Infrastructure (ArgoCD)

| Component        | Description                          |
| ---------------- | ------------------------------------ |
| cert-manager     | Automatic SSL certificate management |
| nginx-ingress    | Ingress controller with autoscaling  |
| external-secrets | Syncs secrets from Azure Key Vault   |

## Adding Secrets to Key Vault

```bash
az keyvault secret set \
  --vault-name devakskv \
  --name database-password \
  --value "your-secret-password"
```

## Deploying Applications

1. Add your application manifests to `kubernetes/applications/dev/`
2. Create an ArgoCD Application manifest
3. Push to Git
4. ArgoCD automatically syncs the deployment

## Customization

### Update Placeholder Values

Search and replace the following placeholders:

- `your-org` - Your GitHub organization
- `your-repo` - Your repository name
- `yourdomain.com` - Your domain
- `your-azure-ad-group-id` - Your Azure AD group object ID

### External Secrets Configuration

After deployment, update:

1. `kubernetes/infrastructure/external-secrets/service-account.yaml` - Add the client ID from Terraform output
2. `kubernetes/infrastructure/external-secrets/cluster-secret-store.yaml` - Add the Key Vault URL

## Contributing

1. Create a feature branch
2. Make changes
3. Submit a pull request

## License

MIT
