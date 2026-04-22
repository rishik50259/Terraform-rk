# ---------------------------------------------
# AWS Provider Configuration
# Purpose: Defines AWS as the provider and region for deployment
# ---------------------------------------------
provider "aws" {
  region = var.region
}

# ---------------------------
# IAM ROLE: EKS CLUSTER
# ---------------------------
# Purpose: Role assumed by EKS control plane
# Allows EKS service to manage cluster resources
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  # Trust policy: allows EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS managed policy required for EKS control plane
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------------------
# IAM ROLE: NODE GROUP
# ---------------------------
# Purpose: Role assumed by EC2 worker nodes in EKS
# Grants permissions required to:
# - Join cluster
# - Communicate with control plane
# - Pull container images
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  # Trust policy: allows EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy: Allows worker nodes to communicate with EKS control plane
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Policy: Required for Kubernetes networking (CNI plugin)
resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Policy: Allows pulling container images from ECR
resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ---------------------------
# EKS CLUSTER (Control Plane)
# ---------------------------
# Purpose: Creates the managed Kubernetes control plane
# AWS manages:
# - API server
# - etcd
# - Control plane components
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = false
    # Cluster is deployed in private subnets for security
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }

    resources = ["secrets"]
  }


  # Ensures IAM role policy is attached before cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secrets Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "eks-secrets-encryption-key"
  }
}



# ---------------------------
# EKS NODE GROUP (Worker Nodes)
# ---------------------------
# Purpose: Creates managed EC2 instances that run application workloads
# These nodes:
# - Register with the EKS cluster
# - Run pods/containers
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "dev-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets

  # Auto Scaling configuration for worker nodes
  scaling_config {
    desired_size = 2   # Number of nodes to run normally
    max_size     = 3   # Maximum nodes during scaling
    min_size     = 1   # Minimum nodes to keep running
  }

  instance_types = ["t3.medium"]   # EC2 instance type for nodes

  # Ensure required IAM policies are attached before node creation
  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registry_policy
  ]
}
