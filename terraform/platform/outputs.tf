output "argocd_url" {
  value = "https://${local.argocd_domain}"
}

output "app_url" {
  value = "https://${local.app_domain}"
}

output "ingress_hostname" {
  value = data.kubernetes_service_v1.ingress.status[0].load_balancer[0].ingress[0].hostname
}
