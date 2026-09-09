# The account cannot create AWS load balancers; expose this lab's single node.
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
    public_ip = data.aws_instance.node.public_ip
  })]

  depends_on = [aws_vpc_security_group_ingress_rule.web]
}
