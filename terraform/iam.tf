# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.resource_prefix}_eks_cluster_role"  # Name of the IAM role

  # Policy that allows EKS to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"  # EKS service is allowed to assume this role
        }
      },
    ]
  })

  # Attach managed policies to the role
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",  # Allows EKS cluster management
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",   # Allows EKS service operations
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",  # Manages VPC resources for EKS
    "arn:aws:iam::aws:policy/AdministratorAccess"  # Provides administrative access
  ]
}

# Create an IAM role for EKS worker nodes (EC2 instances)
resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.resource_prefix}_eks_node_role"  # Name of the IAM role

  # Policy that allows EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # EC2 service is allowed to assume this role
        }
      },
    ]
  })

  # Attach managed policies to the role
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",  # Allows worker nodes to interact with the EKS cluster
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",       # Allows EKS CNI plugin to manage networking
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",  # Allows read-only access to ECR
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",  # Provides full access to EC2
    "arn:aws:iam::aws:policy/AdministratorAccess"  # Provides administrative access
  ]
}
