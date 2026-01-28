# ArgoCD Bootstrap Module
# Installs ArgoCD via Helm and creates the root App of Apps

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        domain = var.argocd_domain
      }

      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }

        cm = {
          "admin.enabled" = var.admin_enabled
          "url"           = "https://${var.argocd_domain}"

          # Repository configuration
          "repositories" = yamlencode([
            {
              type = "git"
              url  = "https://github.com/${var.github_org}/${var.github_repo}"
              name = var.github_repo
            }
          ])
        }

        rbac = {
          "policy.default" = "role:readonly"
          "policy.csv"     = <<-EOT
            g, ${var.admin_group_object_id}, role:admin
          EOT
        }

        secret = {
          createSecret = true
        }
      }

      server = {
        replicas = var.server_replicas

        ingress = {
          enabled          = var.ingress_enabled
          ingressClassName = "nginx"
          annotations = {
            "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          }
          hosts = [var.argocd_domain]
          tls = [{
            secretName = "argocd-server-tls"
            hosts      = [var.argocd_domain]
          }]
        }

        service = {
          type = var.service_type
        }

        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = var.enable_metrics
          }
        }
      }

      controller = {
        replicas = var.controller_replicas

        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = var.enable_metrics
          }
        }
      }

      repoServer = {
        replicas = var.repo_server_replicas

        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = var.enable_metrics
          }
        }
      }

      applicationSet = {
        enabled  = true
        replicas = 1
      }

      notifications = {
        enabled = var.notifications_enabled
      }
    })
  ]
}

# Create ArgoCD root application (App of Apps)
resource "kubernetes_manifest" "argocd_root_application" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "root"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/${var.github_org}/${var.github_repo}"
        targetRevision = var.target_revision
        path           = "kubernetes/bootstrap/${var.environment}"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

# Create ArgoCD project for infrastructure
resource "kubernetes_manifest" "argocd_infrastructure_project" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      name      = "infrastructure"
      namespace = "argocd"
    }

    spec = {
      description = "Infrastructure components managed by ArgoCD"

      sourceRepos = [
        "https://github.com/${var.github_org}/${var.github_repo}",
        "https://charts.jetstack.io",
        "https://kubernetes.github.io/ingress-nginx",
        "https://charts.external-secrets.io"
      ]

      destinations = [{
        namespace = "*"
        server    = "https://kubernetes.default.svc"
      }]

      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]

      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}

# Create ArgoCD project for dev applications
resource "kubernetes_manifest" "argocd_dev_apps_project" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      name      = "dev-apps"
      namespace = "argocd"
    }

    spec = {
      description = "Development applications"

      sourceRepos = [
        "https://github.com/${var.github_org}/${var.github_repo}"
      ]

      destinations = [{
        namespace = "dev-*"
        server    = "https://kubernetes.default.svc"
      }]

      clusterResourceWhitelist = [{
        group = ""
        kind  = "Namespace"
      }]

      namespaceResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]
    }
  }
}
