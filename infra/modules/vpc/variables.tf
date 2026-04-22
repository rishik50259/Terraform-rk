# ---------------------------------------------
# Variable: Region
# Purpose: Defines the AWS region where resources will be deployed
# Keeping this as a variable allows:
# - Reusability across environments (dev, staging, prod)
# - Easy override via tfvars or CLI
# ---------------------------------------------
variable "region" {
  # No type specified → defaults to 'any'
  # Best practice: explicitly define type (e.g., string)
}

# ---------------------------------------------
# Variable: VPC CIDR Block
# Purpose: Defines the IP address range for the VPC
# This CIDR is used to create subnets and allocate private IPs
# Should be carefully planned to avoid overlaps with other networks
# ---------------------------------------------
variable "vpc_cidr" {
  # Example value: "10.0.0.0/16"
  # Best practice: define type = string and add validation
}

# ---------------------------------------------
# Variable: Availability Zones (AZs)
# Purpose: Specifies list of AZs where resources will be deployed
# Enables:
# - High availability
# - Fault tolerance across multiple data centers
# ---------------------------------------------
variable "azs" {
  type = list(string)   # Ensures input is a list of AZ names
  # Example: ["ap-south-1a", "ap-south-1b"]
}