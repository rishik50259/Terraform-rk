# ---------------------------------------------
# AWS Region Configuration
# Purpose: Specifies the AWS region where all resources will be deployed
# Using a variable allows reuse across environments (dev, staging, prod)
# ---------------------------------------------
region = "ap-south-1"

# ---------------------------------------------
# VPC CIDR Block
# Purpose: Defines the IP address range for the VPC
# This range is used to create subnets and assign private IPs to resources
# Example: 10.0.0.0/16 provides ~65,536 IP addresses
# ---------------------------------------------
vpc_cidr = "10.0.0.0/16"

# ---------------------------------------------
# Availability Zones (AZs)
# Purpose: Defines the AZs where resources (like subnets, EKS nodes) will be distributed
# This ensures high availability and fault tolerance
# Example: If one AZ fails, workloads continue in another AZ
# ---------------------------------------------
azs = ["ap-south-1a", "ap-south-1b"]