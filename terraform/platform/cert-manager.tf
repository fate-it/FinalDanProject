resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "oci://quay.io/jetstack/charts"
  chart            = "cert-manager"
  version          = "v1.21.1"
  namespace        = "cert-manager"
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 600

  values = [file("${path.module}/values/cert-manager.yaml")]
}

# Create the custom resource after its CRDs and admission webhook are ready.
# A Helm release also lets Terraform plan this on a cluster without these CRDs.
resource "helm_release" "certificate_issuer" {
  name      = "letsencrypt-issuer"
  chart     = "${path.module}/charts/cluster-issuer"
  namespace = helm_release.cert_manager.namespace
  atomic    = true
  wait      = true
  timeout   = 300

  depends_on = [helm_release.cert_manager]
}
