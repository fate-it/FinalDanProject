data "aws_route53_zone" "group" {
  name         = local.zone_name
  private_zone = false
}

# This lab intentionally has exactly one running worker.
data "aws_instance" "node" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [local.cluster_name]
  }
  filter {
    name   = "tag:eks:nodegroup-name"
    values = ["${local.cluster_name}-workers"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_eks_cluster" "project" {
  name = local.cluster_name
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  for_each          = toset(["80", "443"])
  security_group_id = data.aws_eks_cluster.project.vpc_config[0].cluster_security_group_id
  description       = "Public web access to the single-node nginx ingress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
}

resource "aws_route53_record" "services" {
  for_each = {
    app    = local.app_domain
    argocd = local.argocd_domain
  }

  zone_id = data.aws_route53_zone.group.zone_id
  name    = each.value
  type    = "A"
  ttl     = 60
  records = [data.aws_instance.node.public_ip]
}
