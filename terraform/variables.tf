#AWS region where resources will be provisioned.
variable "aws_region" {
  description = "AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

#AWS profile to be used for authentication.
variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "MayarHossam"
}

#Prefix used for naming infrastructure components to avoid name conflicts.
variable "resource_prefix" {
  description = "Prefix used for naming infrastructure components."
  type        = string
  default     = "team6"
}

#DockerHub image to be deployed in the Kubernetes cluster.
variable "docker_image" {
  description = "DockerHub image to be deployed."
  type        = string
  default     = "mayaremam/library_app:latest"
}

#CIDR block for the Virtual Private Cloud (VPC).
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

#CIDR block for public subnet in availability zone A.
variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet in zone A."
  type        = string
  default     = "10.0.1.0/24"
}

#CIDR block for public subnet in availability zone B.
variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet in zone B."
  type        = string
  default     = "10.0.2.0/24"
}

#CIDR block for private subnet in availability zone A.
variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet in zone A."
  type        = string
  default     = "10.0.3.0/24"
}

#CIDR block for private subnet in availability zone B.
variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet in zone B."
  type        = string
  default     = "10.0.4.0/24"
}

#Name of the EKS cluster.
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "team6-library-app-cluster"
}

#Name of the EKS node group.
variable "node_group_name" {
  description = "Name of the EKS node group."
  type        = string
  default     = "team6-library-app-node-group"
}

#Name of the IAM role for the EKS cluster.
variable "eks_role_name" {
  description = "Name of the role for EKS cluster."
  type        = string
  default     = "team6_eks_cluster_role"
}

#Name of the IAM role for the EKS nodes.
variable "eks_node_role_name" {
  description = "Name of the role for EKS nodes."
  type        = string
  default     = "team6_eks_node_role"
}

#Instance type to be used for EKS nodes.
variable "eks_node_instance_type" {
  description = "Instance type used for EKS nodes."
  type        = string
  default     = "t3.medium"
}

#Minimum number of nodes in the EKS node group.
variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

#Maximum number of nodes in the EKS node group.
variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS node group."
  type        = number
  default     = 2
}

#Desired number of nodes in the EKS node group.
variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS node group."
  type        = number
  default     = 1
}