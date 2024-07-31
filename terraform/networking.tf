resource "aws_vpc" "team_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.resource_prefix}_vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_a
  map_public_ip_on_launch  = true
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.resource_prefix}_public_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.public_subnet_cidr_b
  map_public_ip_on_launch  = true
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.resource_prefix}_public_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_a
  map_public_ip_on_launch  = false
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.resource_prefix}_private_subnet_a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                   = aws_vpc.team_vpc.id
  cidr_block               = var.private_subnet_cidr_b
  map_public_ip_on_launch  = false
  availability_zone        = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.resource_prefix}_private_subnet_b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
