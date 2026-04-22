# ---------------------------------------------
# Region Variable
# Purpose: Declares a variable to define the AWS region dynamically
# This allows flexibility to deploy the same code in different regions
# Value is typically provided via tfvars or CLI
# ---------------------------------------------
variable "region" {
  type = string
}


# ---------------------------------------------
# VPC CIDR Variable
# Purpose: Declares a variable for the VPC IP address range
# Allows different environments (dev/prod) to use different CIDR blocks
# Helps avoid IP conflicts across environments or peered networks
# ---------------------------------------------
variable "vpc_cidr" {
  type = string
}


# ---------------------------------------------
# Availability Zones Variable
# Purpose: Declares a variable for list of AZs to distribute resources
# Type constraint ensures only a list of strings is accepted
# Enables high availability and multi-AZ deployment
# ---------------------------------------------
variable "azs" {
  type = list(string)   # Ensures input is a list of AZ names (e.g., ["ap-south-1a", "ap-south-1b"])
}