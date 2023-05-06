provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_placement_group" "nodes" {
  name     = "${var.cluster_name}-nodes-placement"
  strategy = "spread"
}
resource "aws_instance" "boostrap_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_size
  subnet_id              = aws_subnet.cluster_subnet.id
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]

  tags = {
    Name = "${var.cluster_name}-node"
  }
}




