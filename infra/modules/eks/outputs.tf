# ---------------------------------------------
# Output: EKS Cluster Name
# Purpose: Exposes the name of the created EKS cluster
# This is useful for:
# - Referencing the cluster in other modules or scripts
# - Configuring kubectl (e.g., aws eks update-kubeconfig)
# - Passing as input to CI/CD pipelines or automation tools
# ---------------------------------------------
output "cluster_name" {
  value = aws_eks_cluster.main.name
}