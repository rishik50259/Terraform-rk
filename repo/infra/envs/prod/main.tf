# ---------------------------------------------
# Terraform backend configuration
# Purpose: Store Terraform state remotely in S3
# This helps in:
# - Collaboration across teams
# - State locking (if DynamoDB is added)
# - Preventing local state file issues
# ---------------------------------------------
terraform {
  backend "s3" {
    bucket = "nexflixterraformbe01"   # S3 bucket where state file is stored
    key    = "prod/terraform.tfstate" # Path/name of the state file in the bucket
    region = "ap-south-1"             # AWS region where S3 bucket exists
  }
}

# ---------------------------------------------
# AWS Provider configuration
# Purpose: Defines which cloud provider Terraform will use
# and in which region resources will be created
# ---------------------------------------------
provider "aws" {
  region = var.region # Region is passed as a variable for flexibility (multi-env support)
}

# ---------------------------------------------
# VPC Module
# Purpose: Creates networking infrastructure
# Includes:
# - VPC
# - Subnets (public/private)
# - Availability Zones distribution
# ---------------------------------------------
module "vpc" {
  source = "../../modules/vpc" # Path to reusable VPC module

  region   = var.region   # AWS region
  vpc_cidr = var.vpc_cidr # CIDR block for VPC (e.g., 10.0.0.0/16)
  azs      = var.azs      # List of availability zones for high availability
}

# ---------------------------------------------
# EKS Module
# Purpose: Creates Kubernetes cluster (EKS)
# Uses VPC resources created above
# Includes:
# - EKS control plane
# - Node groups (if defined in module)
# - Networking integration with VPC
# ---------------------------------------------
module "eks" {
  source = "../../modules/eks" # Path to reusable EKS module

  region          = var.region                 # AWS region
  cluster_name    = "dev-eks-cluster"          # Name of the EKS cluster
  private_subnets = module.vpc.private_subnets # Use private subnets from VPC module for secure cluster
}