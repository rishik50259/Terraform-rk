# ---------------------------------------------
# Variable: Region
# Purpose: Defines the AWS region where the EKS cluster and related resources will be created
# Allows flexibility to deploy the same setup across different regions/environments
# ---------------------------------------------
variable "region" {
  # Best practice: define type = string and add description
}

# ---------------------------------------------
# Variable: Cluster Name
# Purpose: Specifies the name of the EKS cluster
# Used for:
# - Identifying the cluster in AWS
# - Configuring kubectl access
# - Referencing in other resources and modules
# ---------------------------------------------
variable "cluster_name" {
  # Example: "dev-eks-cluster"
  # Best practice: define type = string for validation
}

# ---------------------------------------------
# Variable: Private Subnets
# Purpose: Provides list of private subnet IDs where:
# - EKS control plane will be associated
# - Worker nodes (node group) will be deployed
# Ensures cluster is secure (not directly exposed to internet)
# ---------------------------------------------
variable "private_subnets" {
  type = list(string)   # Ensures input is a list of subnet IDs
}