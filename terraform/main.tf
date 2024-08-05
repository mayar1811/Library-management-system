provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.library_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.library_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.library_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  
}


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

resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${var.resource_prefix}_eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}_eks_control_plane_sg"
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.resource_prefix}_eks_nodes_sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}_eks_nodes_sg"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.team_vpc.id
  tags = {
    Name = "${var.resource_prefix}_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.resource_prefix}_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "${var.resource_prefix}_nat_gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.resource_prefix}_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.resource_prefix
  }
}

resource "kubernetes_persistent_volume" "library_app_pv" {
  metadata {
    name = "${var.resource_prefix}-library-app-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "library_app_pvc" {
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_persistent_volume.library_app_pv
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-pvc"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.library_app_pv.metadata[0].name
  }
}

resource "kubernetes_deployment" "library_app" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "${var.resource_prefix}-library-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.resource_prefix}-library-app"
        }
      }

      spec {
        container {
          name  = "${var.resource_prefix}-library-app"
          image = var.docker_image
          port {
            container_port = 5000
          }

          volume_mount {
            name       = "${var.resource_prefix}-library-db-storage"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "${var.resource_prefix}-library-db-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.library_app_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "library_app_service" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 5000
      target_port = 5000
    }

    selector = {
      app = "${var.resource_prefix}-library-app"
    }
  }
}


resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.resource_prefix}_eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.resource_prefix}_eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

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
