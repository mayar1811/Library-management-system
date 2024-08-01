variable "aws_region" {
  description = "AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "MayarHossam"
}

variable "resource_prefix" {
  description = "Prefix used for naming infrastructure components."
  type        = string
  default     = "team6"
}

variable "docker_image" {
  description = "DockerHub image to be deployed."
  type        = string
  default     = "mayaremam/library_app:latest"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet in zone A."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet in zone B."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet in zone A."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet in zone B."
  type        = string
  default     = "10.0.4.0/24"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "team6-library-app-cluster"
}

variable "node_group_name" {
  description = "Name of the EKS node group."
  type        = string
  default     = "team6-library-app-node-group"
}

variable "eks_role_name" {
  description = "Name of the role for EKS cluster."
  type        = string
  default     = "team6_eks_cluster_role"
}

variable "eks_node_role_name" {
  description = "Name of the role for EKS nodes."
  type        = string
  default     = "team6_eks_node_role"
}

variable "eks_node_instance_type" {
  description = "Instance type used for EKS nodes."
  type        = string
  default     = "t3.medium"
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS node group."
  type        = number
  default     = 2
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS node group."
  type        = number
  default     = 1
}
