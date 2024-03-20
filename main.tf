locals {
  user = "ubuntu"
  topology = {
    for index, node in var.cluster_topology :
    node.name => merge(node, { subnet = node.id % length(var.public_subnet_ids) })
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
  name     = "${var.identifier}-nodes-placement"
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
    "lxc cluster add ${var.identifier}-node-${each.key} | sed '1d; /^$/d'"
  ]
}

resource "aws_instance" "bootstrap_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_size
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = var.node_monitoring
  user_data_base64       = data.cloudinit_config.node.rendered

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.storage_size
    volume_type = var.volume_type
    encrypted   = true
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
      server_name  = "${var.identifier}-bootstrap-node"
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
    Name = "${var.identifier}-bootstrap-node"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data_base64,
      subnet_id
    ]
  }
}

resource "aws_instance" "nodes" {
  for_each = local.topology

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.size
  subnet_id              = var.public_subnet_ids[each.value.subnet]
  vpc_security_group_ids = [aws_security_group.nodes_firewall.id]
  placement_group        = aws_placement_group.nodes.id
  ebs_optimized          = true
  monitoring             = var.node_monitoring
  user_data_base64       = data.cloudinit_config.node.rendered

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.storage_size
    volume_type = var.volume_type
    encrypted   = true
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
    Name      = "${var.identifier}-node-${each.key}"
    Blueprint = var.blueprint
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data_base64
    ]
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
    commands = contains(yamldecode(ssh_resource.node_detail[each.key].result).roles, "database-leader") ? ["echo Node is database-leader restarting later", "sudo shutdown -r +1"] : [
      "sudo reboot"
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
    on_failure = continue
    inline     = self.input.commands
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
    commands = contains(yamldecode(ssh_resource.node_detail[each.key].result).roles, "database-leader") ? [
      "echo ${var.protect_leader ? "Node is database-leader cannot destroy" : "Tearing it all down"}",
      "${var.protect_leader ? "exit 1" : "exit 0"}"
      ] : [
      "lxc cluster remove --force --yes ${aws_instance.nodes[each.key].tags.Name}"
    ]
  }

  depends_on = [
    aws_instance.bastion,
    aws_instance.bootstrap_node,
    var.public_subnet_ids,
    var.vpc_id,
    var.network_dependencies,
    aws_security_group.nodes_firewall,
    aws_security_group.bastion_firewall
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

resource "aws_security_group" "nodes_firewall" {
  name        = "${var.identifier}-instellar-nodes"
  description = "Instellar Nodes Configuration"
  vpc_id      = var.vpc_id

  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description      = "Egress to everywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.identifier}-instellar"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "cross_nodes" {
  security_group_id            = aws_security_group.nodes_firewall.id
  description                  = "Full Cross Node Communication"
  from_port                    = 1
  to_port                      = 65535
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.nodes_firewall.id

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_bastion" {
  security_group_id            = aws_security_group.nodes_firewall.id
  description                  = "Connect from Bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_firewall.id

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_http" {
  count = var.publically_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public http for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_https" {
  count = var.publically_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public https for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_lxd" {
  count = var.publically_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public lxd for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_uplink" {
  count = var.publically_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public uplink for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 49152
  to_port           = 49152
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}
