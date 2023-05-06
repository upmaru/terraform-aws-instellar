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

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.cluster_name}-public-${count.index + 1}"
  }
}

resource "aws_security_group" "bastion_firewall" {
  name        = "${var.cluster_name}-instellar-bastion"
  description = "Instellar Bastion Configuration"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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

resource "aws_security_group" "nodes_firewall" {
  name        = "${var.cluster_name}-instellar-nodes"
  description = "Instellar Nodes Configuration"
  vpc_id      = aws_vpc.cluster_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "LXD"
    from_port        = 8443
    to_port          = 8443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Uplink"
    from_port        = 49152
    to_port          = 49152
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "From Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_firewall.id]
  }

  ingress {
    description = "Full Cross Node TCP"
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Full Cross Nod UDP"
    from_port   = 1
    to_port     = 65535
    protocol    = "udp"
    self        = true
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