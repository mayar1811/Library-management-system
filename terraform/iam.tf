# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.resource_prefix}_eks_cluster_role"

  # Policy that allows the EKS service and specific IAM users to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::637423483309:user/Nour",
            "arn:aws:iam::637423483309:user/MayarHossam",
            "arn:aws:iam::637423483309:user/ibrahmed",
            "arn:aws:iam::637423483309:user/AhmedHazem",
          ]
        }
      },
    ]
  })

  # Managed policies attached to the EKS cluster role
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",        # Provides permissions to manage EKS clusters
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",        # Provides permissions for EKS service operations
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController", # Provides permissions to manage VPC resources
    "arn:aws:iam::aws:policy/AdministratorAccess"             # Provides full administrative access
  ]
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.resource_prefix}_eks_node_role"

  # Policy that allows EC2 instances and specific IAM users to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::637423483309:user/Nour",
            "arn:aws:iam::637423483309:user/MayarHossam",
            "arn:aws:iam::637423483309:user/ibrahmed",
            "arn:aws:iam::637423483309:user/AhmedHazem",
          ]
        }
      },
    ]
  })

  # Managed policies attached to the EKS worker nodes role
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",     # Provides permissions for EKS worker nodes
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",         # Provides permissions for the Amazon VPC CNI plugin
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # Provides read-only access to ECR
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",          # Provides full access to EC2 resources
    "arn:aws:iam::aws:policy/AdministratorAccess"            # Provides full administrative access
  ]
}
