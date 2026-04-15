terraform {
  backend "s3" {
    bucket = "nexflixterraformbe01"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  region    = var.region
  vpc_cidr  = var.vpc_cidr
  azs       = var.azs
}

module "eks" {
  source = "../../modules/eks"

  region          = var.region
  cluster_name    = "dev-eks-cluster"
  private_subnets = module.vpc.private_subnets
}