# Define an EKS cluster resource
resource "aws_eks_cluster" "library_cluster" {
  depends_on = [aws_iam_role.eks_cluster_role]  # Ensure the IAM role is created before the cluster

  name     = var.cluster_name  # Name of the EKS cluster
  role_arn = aws_iam_role.eks_cluster_role.arn  # IAM role ARN for the cluster

  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]  # Subnets for the cluster
    security_group_ids = [aws_security_group.eks_control_plane_sg.id]  # Security group for the control plane
  }

  timeouts {
    create = "30m"  # Timeout for creating the cluster
    delete = "30m"  # Timeout for deleting the cluster
  }
}

# Define an EKS node group resource
resource "aws_eks_node_group" "library_node_group" {
  cluster_name    = var.cluster_name  # Name of the EKS cluster
  node_group_name = var.node_group_name  # Name of the node group
  node_role_arn   = aws_iam_role.eks_nodes_role.arn  # IAM role ARN for the nodes
  subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]  # Subnets for the node group

  scaling_config {
    desired_size = var.eks_node_desired_size  # Desired number of nodes
    max_size     = var.eks_node_max_size      # Maximum number of nodes
    min_size     = var.eks_node_min_size      # Minimum number of nodes
  }

  depends_on = [
    aws_eks_cluster.library_cluster,  # Ensure the EKS cluster is created before the node group
    aws_iam_role.eks_nodes_role       # Ensure the IAM role is created before the node group
  ]
}
