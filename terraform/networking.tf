# Create a VPC with the specified CIDR block and name tag
resource "aws_vpc" "team_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.resource_prefix}_vpc"
  }
}

# Create a public subnet in availability zone A
resource "aws_subnet" "public_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_a
  map_public_ip_on_launch  = true  # Automatically assign a public IP to instances in this subnet
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.resource_prefix}_public_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # Tag to indicate this subnet is shared with a Kubernetes cluster
    "kubernetes.io/role/elb" = "1"  # Tag to indicate this subnet is used for ELB (Elastic Load Balancer)
  }
}

# Create a public subnet in availability zone B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_b
  map_public_ip_on_launch  = true  # Automatically assign a public IP to instances in this subnet
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.resource_prefix}_public_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # Tag to indicate this subnet is shared with a Kubernetes cluster
    "kubernetes.io/role/elb" = "1"  # Tag to indicate this subnet is used for ELB (Elastic Load Balancer)
  }
}

# Create a private subnet in availability zone A
resource "aws_subnet" "private_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_a
  map_public_ip_on_launch  = false  # Do not automatically assign a public IP to instances in this subnet
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.resource_prefix}_private_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # Tag to indicate this subnet is shared with a Kubernetes cluster
    "kubernetes.io/role/internal-elb" = "1"  # Tag to indicate this subnet is used for internal ELB (Elastic Load Balancer)
  }
}

# Create a private subnet in availability zone B
resource "aws_subnet" "private_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_b
  map_public_ip_on_launch  = false  # Do not automatically assign a public IP to instances in this subnet
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.resource_prefix}_private_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  # Tag to indicate this subnet is shared with a Kubernetes cluster
    "kubernetes.io/role/internal-elb" = "1"  # Tag to indicate this subnet is used for internal ELB (Elastic Load Balancer)
  }
}
