# Matches the course's NLB integration with the EKS AWS cloud provider.
# "nlb" deliberately uses the legacy EKS service controller, not Auto Mode or LBC.
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.15.1"
  namespace        = "ingress-nginx"
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 900

  values = [templatefile("${path.module}/values/ingress-nginx.yaml.tftpl", {
    certificate_arn = aws_acm_certificate_validation.ingress.certificate_arn
    subnet_ids      = join(",", local.eks.public_subnet_ids)
  })]
}

data "kubernetes_service_v1" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx.namespace
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "aws_route53_record" "services" {
  for_each = {
    app    = local.app_domain
    argocd = local.argocd_domain
  }

  zone_id = data.aws_route53_zone.group.zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_service_v1.ingress.status[0].load_balancer[0].ingress[0].hostname]
}
