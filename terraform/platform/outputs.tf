output "argocd_url" {
  value = "https://${local.argocd_domain}"
}

output "app_url" {
  value = "https://${local.app_domain}"
}

output "ingress_ip" {
  value = data.aws_instance.node.public_ip
}
