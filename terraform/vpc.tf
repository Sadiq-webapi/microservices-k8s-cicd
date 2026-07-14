#############################
# VPC
#############################

resource "aws_vpc" "minikube_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "minikube-vpc"
  }
}

#############################
# Public Subnet
#############################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.minikube_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "minikube-public-subnet"
  }
}

#############################
# Internet Gateway
#############################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minikube_vpc.id

  tags = {
    Name = "minikube-igw"
  }
}

#############################
# Public Route Table
#############################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minikube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "minikube-public-rt"
  }
}

#############################
# Route Table Association
#############################

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}