# ---------------------------------------------
# AWS Provider Configuration
# Purpose: Defines AWS as the cloud provider
# and specifies the region where resources will be created
# ---------------------------------------------
provider "aws" {
  region = var.region   # Region is passed dynamically via variable
}

# ---------------------------------------------
# VPC (Virtual Private Cloud)
# Purpose: Creates an isolated network in AWS
# Enables DNS support for internal communication
# ---------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr         # Defines IP range for VPC
  enable_dns_support   = true                 # Enables DNS resolution inside VPC
  enable_dns_hostnames = true                 # Allows instances to have DNS hostnames

  tags = {
    Name = "dev-vpc"                          # Tag for identification
  }
}

# ---------------------------------------------
# Internet Gateway (IGW)
# Purpose: Enables internet access for public subnets
# ---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id                   # Attach IGW to the VPC
}

# ---------------------------------------------
# Public Subnets
# Purpose: Subnets with direct internet access
# Typically used for:
# - Load balancers
# - Bastion hosts
# ---------------------------------------------
resource "aws_subnet" "public" {
  count = 2                                  # Creates 2 public subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  # Splits VPC CIDR into smaller subnets dynamically

  availability_zone       = element(var.azs, count.index)
  # Distributes subnets across AZs for high availability

  map_public_ip_on_launch = true
  # Automatically assigns public IPs to instances

  tags = {
    Name = "public-${count.index}"
  }
}

# ---------------------------------------------
# Private Subnets
# Purpose: Subnets without direct internet access
# Typically used for:
# - Application servers
# - Databases
# ---------------------------------------------
resource "aws_subnet" "private" {
  count = 2                                  # Creates 2 private subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  # Uses different CIDR ranges than public subnets

  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "private-${count.index}"
  }
}

# ---------------------------------------------
# Elastic IP for NAT Gateway
# Purpose: Provides a static public IP for NAT Gateway
# ---------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

# ---------------------------------------------
# NAT Gateway
# Purpose: Allows private subnet instances to access the internet
# (for updates, downloads) without being exposed publicly
# ---------------------------------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id              # Associates Elastic IP
  subnet_id     = aws_subnet.public[0].id     # NAT must be in a public subnet
}

# ---------------------------------------------
# Public Route Table
# Purpose: Defines routing rules for public subnets
# ---------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# ---------------------------------------------
# Public Route to Internet
# Purpose: Routes all outbound traffic to Internet Gateway
# ---------------------------------------------
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"         # All traffic
  gateway_id             = aws_internet_gateway.igw.id
}

# ---------------------------------------------
# Associate Public Subnets with Public Route Table
# Purpose: Enables internet access for public subnets
# ---------------------------------------------
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------
# Private Route Table
# Purpose: Defines routing rules for private subnets
# ---------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# ---------------------------------------------
# Private Route via NAT Gateway
# Purpose: Allows private subnets to access internet securely
# without exposing them directly
# ---------------------------------------------
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# ---------------------------------------------
# Associate Private Subnets with Private Route Table
# Purpose: Applies NAT-based routing to private subnets
# ---------------------------------------------
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}