# Create a VPC
resource "aws_vpc" "cluster_vpc" {
  cidr_block = var.vpc_ip_range
}

resource "aws_internet_gateway" "cluster_gw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_subnet" "cluster_subnet" {
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group" "instellar" {
  name        = "${var.cluster_name}-instellar"
  description = "Instellar Configuration"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.cluster_vpc.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.cluster_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.cluster_vpc.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.cluster_vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.cluster_name}-instellar"
  }
}