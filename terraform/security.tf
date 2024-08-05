# Security group for the EKS control plane
resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${var.resource_prefix}_eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.team_vpc.id

  # Ingress rule allowing TCP traffic on port 5000 from any IP
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags for the security group
  tags = {
    Name = "${var.resource_prefix}_eks_control_plane_sg"
  }
}

# Security group for EKS nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.resource_prefix}_eks_nodes_sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.team_vpc.id

  # Ingress rule allowing TCP traffic on port 5000 from any IP
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags for the security group
  tags = {
    Name = "${var.resource_prefix}_eks_nodes_sg"
  }
}

# Internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.team_vpc.id

  # Tags for the internet gateway
  tags = {
    Name = "${var.resource_prefix}_igw"
  }
}

# Public route table for the VPC
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  # Route for internet access through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Tags for the public route table
  tags = {
    Name = "${var.resource_prefix}_public_route_table"
  }
}

# Associate public route table with subnet A
resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate public route table with subnet B
resource "aws_route_table_association" "public_route_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Elastic IP for the NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT gateway for private subnet internet access
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  # Tags for the NAT gateway
  tags = {
    Name = "${var.resource_prefix}_nat_gateway"
  }
}

# Private route table for the VPC
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  # Route for internet access through the NAT gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  # Tags for the private route table
  tags = {
    Name = "${var.resource_prefix}_private_route_table"
  }
}

# Associate private route table with subnet A
resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with subnet B
resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}
