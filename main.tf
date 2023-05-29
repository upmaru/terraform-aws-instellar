provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

locals {
  user = "ubuntu"
  topology = {
    for index, node in var.cluster_topology :
    node.name => merge(node, { subnet = node.id % length(var.public_subnet_cidrs) })
  }
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

resource "ssh_resource" "trust_token" {
  host         = aws_instance.bootstrap_node.private_ip
  bastion_host = aws_instance.bastion.public_ip

  user         = local.user
  bastion_user = local.user

  private_key         = tls_private_key.bastion_key.private_key_openssh
  bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh

  commands = [
    "lxc config trust add --name instellar | sed '1d; /^$/d'"
  ]
}

resource "ssh_resource" "cluster_join_token" {
  for_each = local.topology

  host         = aws_instance.bootstrap_node.private_ip
  bastion_host = aws_instance.bastion.public_ip

  user         = local.user
  bastion_user = local.user

  private_key         = tls_private_key.bastion_key.private_key_openssh
  bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh

  commands = [
    "lxc cluster add ${var.cluster_name}-node-${each.key} | sed '1d; /^$/d'"
  ]
}
resource "aws_instance" "bootstrap_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_size
  subnet_id              = aws_subnet.public_subnets[1].id
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = var.node_monitoring
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
  for_each = local.topology

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.size
  subnet_id              = aws_subnet.public_subnets[each.value.subnet].id
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = var.node_monitoring
  user_data_base64       = data.cloudinit_config.node.rendered

  root_block_device {
    volume_size = var.storage_size
    volume_type = var.volume_type
  }

  connection {
    type                = "ssh"
    user                = local.user
    host                = self.private_ip
    private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_user        = local.user
    bastion_host        = aws_instance.bastion.public_ip
    bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/lxd-join.yml.tpl", {
      ip_address   = self.private_ip
      join_token   = ssh_resource.cluster_join_token[each.key].result
      storage_size = "${var.storage_size - 10}"
    })

    destination = "/tmp/lxd-join.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "lxd init --preseed < /tmp/lxd-join.yml"
    ]
  }

  tags = {
    Name = "${var.cluster_name}-node-${each.key}"
  }
}

resource "ssh_resource" "node_detail" {
  for_each = local.topology

  triggers = {
    always_run = "${timestamp()}"
  }

  host         = aws_instance.bootstrap_node.private_ip
  bastion_host = aws_instance.bastion.public_ip

  user         = local.user
  bastion_user = local.user

  private_key         = tls_private_key.bastion_key.private_key_openssh
  bastion_private_key = tls_private_key.terraform_cloud.private_key_openssh

  commands = [
    "lxc cluster show ${aws_instance.nodes[each.key].tags.Name}"
  ]
}

resource "terraform_data" "reboot" {
  for_each = local.topology

  input = {
    user                        = local.user
    node_name                   = aws_instance.nodes[each.key].tags.Name
    bastion_private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_public_ip           = aws_instance.bastion.public_ip
    node_private_ip             = aws_instance.nodes[each.key].private_ip
    terraform_cloud_private_key = tls_private_key.terraform_cloud.private_key_openssh
    commands = contains(yamldecode(ssh_resource.node_detail[each.key].result).roles, "database-leader") ? ["echo Node is database-leader restarting later", "sudo shutdown -r +2"] : [
      "sudo shutdown -r +1"
    ]
  }

  connection {
    type                = "ssh"
    user                = self.input.user
    host                = self.input.node_private_ip
    private_key         = self.input.bastion_private_key
    bastion_user        = self.input.user
    bastion_host        = self.input.bastion_public_ip
    bastion_private_key = self.input.terraform_cloud_private_key
    timeout             = "10s"
  }

  provisioner "remote-exec" {
    inline = self.input.commands
  }
}

resource "terraform_data" "removal" {
  for_each = local.topology

  input = {
    user                        = local.user
    node_name                   = aws_instance.nodes[each.key].tags.Name
    bastion_private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_public_ip           = aws_instance.bastion.public_ip
    bootstrap_node_private_ip   = aws_instance.bootstrap_node.private_ip
    terraform_cloud_private_key = tls_private_key.terraform_cloud.private_key_openssh
    commands = contains(yamldecode(ssh_resource.node_detail[each.key].result).roles, "database-leader") ? ["echo ${var.protect_leader ? "Node is database-leader cannot destroy" : "Tearing it all down"}", "exit ${var.protect_leader ? 1 : 0}"] : [
      "lxc cluster evac --force ${aws_instance.nodes[each.key].tags.Name}",
      "lxc cluster remove --force --yes ${aws_instance.nodes[each.key].tags.Name}"
    ]
  }

  depends_on = [
    aws_instance.bastion,
    aws_instance.bootstrap_node,
    aws_subnet.public_subnets,
    aws_vpc.cluster_vpc,
    aws_internet_gateway.cluster_gw,
    aws_security_group.nodes_firewall,
    aws_security_group.bastion_firewall,
    aws_route_table.public,
    aws_route_table_association.public_subnet_assoc,
  ]

  connection {
    type                = "ssh"
    user                = self.input.user
    host                = self.input.bootstrap_node_private_ip
    private_key         = self.input.bastion_private_key
    bastion_user        = self.input.user
    bastion_host        = self.input.bastion_public_ip
    bastion_private_key = self.input.terraform_cloud_private_key
    timeout             = "10s"
  }

  provisioner "remote-exec" {
    when   = destroy
    inline = self.input.commands
  }
}





