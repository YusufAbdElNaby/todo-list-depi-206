
# Auto-generate a name prefix for resources
variable "name_prefix" {
  default = "DevOps-DEPI-206"
}

# VPC creation
resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/21"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name_prefix}-vpc","kubernetes.io/cluster/DevOps-DEPI-206-eks-cluster" = "shared"
  }
 

}

/*
CIDR Block Information
P Address:	10.30.0.0
Network Address:	10.30.0.0
Usable Host IP Range:	10.30.0.1 - 10.30.7.254
Broadcast Address:	10.30.7.255
Total Number of Hosts:	2,048
Number of Usable Hosts:	2,046
Subnet Mask:	255.255.248.0
*/

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# Public subnets creation
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.0.0/24"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-a"
    "kubernetes.io/cluster/DevOps-DEPI-206-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = "eu-west-3b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-b"
    "kubernetes.io/cluster/DevOps-DEPI-206-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# Private subnets creation
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.2.0/24"
  availability_zone = "eu-west-3a"
  tags = {
    Name = "${var.name_prefix}-private-a"
    "kubernetes.io/cluster/DevOps-DEPI-206-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.3.0/24"
  availability_zone = "eu-west-3b"
  tags = {
    Name = "${var.name_prefix}-private-b" 
    "kubernetes.io/cluster/DevOps-DEPI-206-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1 
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

# Associate public route tables with public subnets
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway creation in each AZ
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "${var.name_prefix}-nat-gw-a"
  }
}

resource "aws_eip" "nat_eip_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id
  tags = {
    Name = "${var.name_prefix}-nat-gw-b"
  }
}

# Private Route Table creation and NAT association
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "${var.name_prefix}-private-rt-a"
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_b.id
  }
  tags = {
    Name = "${var.name_prefix}-private-rt-b"
  }
}

# Associate private route tables with private subnets
resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.eu-west-3.s3"
  tags = {
    Name = "${var.name_prefix}-s3-endpoint"
  }
}

