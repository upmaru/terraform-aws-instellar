# Create a VPC

locals {
  create_network       = var.block_type == "foundation"
  public_subnets_count = length(var.public_subnet_cidrs)
}

resource "aws_vpc" "this" {
  count                = local.create_network ? 1 : 0
  cidr_block           = var.vpc_ip_range
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "this" {
  count  = local.create_network ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "${var.identifier}-gateway"
  }
}

resource "aws_route_table" "public" {
  count  = local.create_network ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "${var.identifier}-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = local.create_network ? local.public_subnets_count : 0
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

#tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "public_subnets" {
  count             = local.create_network ? local.public_subnets_count : 0
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.identifier}-public-${count.index + 1}"
  }
}