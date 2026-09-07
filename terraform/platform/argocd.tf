resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.11"
  namespace        = "argocd"
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 900

  values = [templatefile("${path.module}/values/argocd.yaml.tftpl", {
    argocd_domain = local.argocd_domain
  })]

  depends_on = [helm_release.ingress_nginx]
}
