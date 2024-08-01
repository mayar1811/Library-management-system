output "eks_cluster_name" {
  value = aws_eks_cluster.library_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.library_cluster.endpoint
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.library_cluster.arn
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.library_cluster.certificate_authority[0].data
}

output "eks_node_group_name" {
  value = aws_eks_node_group.library_node_group.node_group_name
}

output "eks_node_group_arn" {
  value = aws_eks_node_group.library_node_group.arn
}

output "vpc_id" {
  value = aws_vpc.team_vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_subnet_b.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata[0].name
}

output "persistent_volume_claim_name" {
  value = kubernetes_persistent_volume_claim.library_app_pvc.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.library_app.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.library_app_service.metadata[0].name
}
