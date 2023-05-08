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

data "cloudinit_config" "node" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yml.tpl", {
      ssh_keys = [tls_private_key.bastion_key.public_key_openssh]
    })
  }
}

resource "ssh_resource" "cluster_join_token" {
  count        = var.cluster_size
  host         = aws_instance.boostrap_node.private_ip
  bastion_host = aws_instance.bastion.public_ip

  user         = "ubuntu"
  bastion_user = "ubuntu"

  private_key         = tls_private_key.bastion_key.private_key_openssh
  bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh

  commands = [
    "lxc cluster add ${var.cluster_name}-node-${format("%02d", count.index + 1)} | sed '1d; /^$/d'"
  ]
}
resource "aws_instance" "boostrap_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_size
  subnet_id              = aws_subnet.public_subnets[1].id
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = true
  user_data_base64       = data.cloudinit_config.node.rendered

  root_block_device {
    volume_size = var.storage_size
  }

  connection {
    type                = "ssh"
    user                = "ubuntu"
    host                = self.private_ip
    private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_user        = "ubuntu"
    bastion_host        = aws_instance.bastion.public_ip
    bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/lxd-init.yml.tpl", {
      ip_address   = self.private_ip
      server_name  = "${var.cluster_name}-bootstrap-node"
      storage_size = "${var.storage_size - 10}"
      vpc_ip_range = var.vpc_ip_range
    })

    destination = "/tmp/lxd-init.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "lxd init --preseed < /tmp/lxd-init.yml"
    ]
  }

  tags = {
    Name = "${var.cluster_name}-bootstrap-node"
  }
}

resource "aws_instance" "nodes" {
  count                  = var.cluster_size
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_size
  subnet_id              = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = true
  user_data_base64       = data.cloudinit_config.node.rendered

  root_block_device {
    volume_size = var.storage_size
  }

  connection {
    type                = "ssh"
    user                = "ubuntu"
    host                = self.private_ip
    private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_user        = "ubuntu"
    bastion_host        = aws_instance.bastion.public_ip
    bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/lxd-join.yml.tpl", {
      ip_address   = self.private_ip
      join_token   = ssh_resource.cluster_join_token[count.index].result
      storage_size = "${var.storage_size - 10}"
    })

    destination = "/tmp/lxd-join.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "lxd init --preseed < /tmp/lxd-join.yml",
      "sudo shutdown -r +1"
    ]
  }

  tags = {
    Name = "${var.cluster_name}-node-${format("%02d", count.index + 1)}"
  }
}

resource "terraform_data" "removal" {
  count = var.cluster_size
  input = {
    bastion_private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_public_ip           = aws_instance.bastion.public_ip
    bootstrap_node_private_ip   = aws_instance.boostrap_node.private_ip
    terraform_cloud_private_key = tls_private_key.terraform_cloud.private_key_openssh
  }

  triggers_replace = aws_instance.nodes[count.index].tags.Name

  connection {
    type                = "ssh"
    user                = "ubuntu"
    host                = self.input.bootstrap_node_private_ip
    private_key         = self.input.bastion_private_key
    bastion_user        = "ubuntu"
    bastion_host        = self.input.bastion_public_ip
    bastion_private_key = self.input.terraform_cloud_private_key
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "lxc cluster remove ${self.triggers_replace}"
    ]
  }
}




