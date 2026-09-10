terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

# Separate states avoid configuring Kubernetes/Helm before the cluster exists.
# Both directories use separate local state files.
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = abspath("${path.module}/../eks/terraform.tfstate")
  }
}

locals {
  eks           = data.terraform_remote_state.eks.outputs
  cluster_name  = local.eks.cluster_name
  region        = local.eks.region
  zone_name     = local.eks.zone_name
  group_number  = local.eks.group_number
  group_domain  = "devops${local.group_number}.${local.zone_name}"
  base_domain   = "${local.cluster_name}.${local.group_domain}"
  argocd_domain = "argocd.${local.base_domain}"
  app_domain    = "app.${local.base_domain}"
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project   = "FinalDanProject"
      Cluster   = local.cluster_name
      ManagedBy = "Terraform"
    }
  }
}

provider "kubernetes" {
  host                   = local.eks.endpoint
  cluster_ca_certificate = base64decode(local.eks.certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--region", local.region]
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.eks.endpoint
    cluster_ca_certificate = base64decode(local.eks.certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--region", local.region]
    }
  }
}
