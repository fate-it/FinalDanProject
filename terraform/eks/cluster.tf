# Adapted from the course EKS/eks-cluster.tf and EKS/eks-worker-nodes.tf.
resource "aws_eks_cluster" "project" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.api_allowed_cidrs
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

resource "aws_eks_node_group" "project" {
  cluster_name    = aws_eks_cluster.project.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id
  version         = var.kubernetes_version
  ami_type        = "AL2023_x86_64_STANDARD"
  instance_types  = [var.node_instance_type]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = { "node-type" = "tests" }

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_route.internet,
    aws_route_table_association.public,
  ]
}

# Adopt the EKS bootstrap add-ons and choose versions compatible with the cluster.
data "aws_eks_addon_version" "system" {
  for_each           = toset(["vpc-cni", "kube-proxy", "coredns"])
  addon_name         = each.value
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "system" {
  for_each                    = data.aws_eks_addon_version.system
  cluster_name                = aws_eks_cluster.project.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.project]
}
