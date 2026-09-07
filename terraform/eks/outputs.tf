output "cluster_name" {
  value = aws_eks_cluster.project.name
}

output "region" {
  value = var.region
}

output "zone_name" {
  value = var.zone_name
}

output "group_number" {
  value = var.group_number
}

output "endpoint" {
  value = aws_eks_cluster.project.endpoint
}

output "certificate_authority_data" {
  value = aws_eks_cluster.project.certificate_authority[0].data
}

output "vpc_id" {
  value = aws_vpc.project.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.project.name}"
}
