# Output the name of the EKS cluster
output "eks_cluster_name" {
  value = aws_eks_cluster.library_cluster.name
}

# Output the endpoint URL of the EKS cluster
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.library_cluster.endpoint
}

# Output the Amazon Resource Name (ARN) of the EKS cluster
output "eks_cluster_arn" {
  value = aws_eks_cluster.library_cluster.arn
}

# Output the certificate authority data for the EKS cluster
output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.library_cluster.certificate_authority[0].data
}

# Output the name of the EKS node group
output "eks_node_group_name" {
  value = aws_eks_node_group.library_node_group.node_group_name
}

# Output the Amazon Resource Name (ARN) of the EKS node group
output "eks_node_group_arn" {
  value = aws_eks_node_group.library_node_group.arn
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.team_vpc.id
}

# Output the ID of public subnet A
output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

# Output the ID of public subnet B
output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

# Output the ID of private subnet A
output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}

# Output the ID of private subnet B
output "private_subnet_b_id" {
  value = aws_subnet.private_subnet_b.id
}

# Output the ID of the NAT gateway
output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

# Output the ID of the internet gateway
output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

# Output the name of the Kubernetes namespace
output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata[0].name
}

# Output the name of the Kubernetes PersistentVolumeClaim
output "persistent_volume_claim_name" {
  value = kubernetes_persistent_volume_claim.library_app_pvc.metadata[0].name
}

# Output the name of the Kubernetes Deployment
output "deployment_name" {
  value = kubernetes_deployment.library_app.metadata[0].name
}

# Output the name of the Kubernetes Service
output "service_name" {
  value = kubernetes_service.library_app_service.metadata[0].name
}
