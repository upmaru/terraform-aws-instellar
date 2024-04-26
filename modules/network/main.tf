locals {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_ip_range
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.identifier}-vpc"
    Blueprint = var.blueprint
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = "${var.identifier}-gateway"
    Blueprint = var.blueprint
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = "${var.identifier}-public-route-table"
    Blueprint = var.blueprint
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.this[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

#tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "this" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(local.availability_zones, count.index)

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = {
    Name      = "${var.identifier}-public-${count.index + 1}"
    Blueprint = var.blueprint
  }
}