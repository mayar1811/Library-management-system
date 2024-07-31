resource "aws_eks_cluster" "library_cluster" {
  depends_on = [aws_iam_role.eks_cluster_role]

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_group_ids = [aws_security_group.eks_control_plane_sg.id]
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "aws_eks_node_group" "library_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  depends_on = [
    aws_eks_cluster.library_cluster,
    aws_iam_role.eks_nodes_role
  ]
}
