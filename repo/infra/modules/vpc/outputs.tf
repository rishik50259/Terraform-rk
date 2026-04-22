# ---------------------------------------------
# Output: VPC ID
# Purpose: Exposes the ID of the created VPC
# This is useful for:
# - Referencing this VPC in other modules (e.g., EKS, RDS)
# - Debugging and verification after deployment
# ---------------------------------------------
output "vpc_id" {
  value = aws_vpc.main.id
}

# ---------------------------------------------
# Output: Private Subnet IDs
# Purpose: Exposes list of private subnet IDs
# Used by:
# - EKS clusters (for worker nodes)
# - Databases or internal services
# - Any resource that should not be publicly accessible
# ---------------------------------------------
output "private_subnets" {
  value = aws_subnet.private[*].id   # Splat expression to return all private subnet IDs
}

# ---------------------------------------------
# Output: Public Subnet IDs
# Purpose: Exposes list of public subnet IDs
# Used by:
# - Load balancers (ALB/NLB)
# - Bastion hosts
# - NAT Gateway placement
# ---------------------------------------------
output "public_subnets" {
  value = aws_subnet.public[*].id    # Splat expression to return all public subnet IDs
}