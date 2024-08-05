# Configuring the AWS provider with the specified region and profile
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Retrieving the list of available AWS availability zones
data "aws_availability_zones" "available" {}

# Fetching authentication details for the specified EKS cluster
data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.library_cluster.name
}

# Configuring the Kubernetes provider to connect to the EKS cluster
provider "kubernetes" {
  host                   = aws_eks_cluster.library_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.library_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

