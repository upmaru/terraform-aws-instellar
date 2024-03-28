locals {
  user                    = "ubuntu"
  ssh_port                = 22
  node_detail_refreshable = var.bastion_ssh || var.balancer_ssh
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

module "balancer" {
  count = var.balancer ? 1 : 0

  source = "./modules/balancer"

  ssh                       = var.balancer_ssh
  bastion_security_group_id = aws_security_group.bastion_firewall.id
  nodes_security_group_id   = aws_security_group.nodes_firewall.id
  deletion_protection       = var.balancer_deletion_protection
  blueprint                 = var.blueprint
  identifier                = var.identifier
  vpc_id                    = var.vpc_id
  subnet_ids                = var.public_subnet_ids

  bastion_node = {
    id        = aws_instance.bastion.id
    slug      = aws_instance.bastion.tags.Name
    public_ip = aws_instance.bastion.public_ip
  }
  bootstrap_node = {
    slug      = aws_instance.bootstrap_node.tags.Name
    public_ip = aws_instance.bootstrap_node.public_ip
    id        = aws_instance.bootstrap_node.id
  }
  nodes = [
    for key, node in aws_instance.nodes :
    {
      slug      = node.tags.Name
      public_ip = node.public_ip
      id        = node.id
    }
  ]
}

resource "aws_iam_instance_profile" "nodes" {
  name = "${var.identifier}-nodes-profile"
  role = aws_iam_role.nodes.name

  tags = {
    Blueprint = var.blueprint
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

  iam_instance_profile = aws_iam_instance_profile.nodes.name

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
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
    Name      = "${var.identifier}-bootstrap-node"
    Blueprint = var.blueprint
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

  iam_instance_profile = aws_iam_instance_profile.nodes.name

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
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

resource "random_uuid" "node_detail" {
  keepers = {
    revision = var.node_detail_revision
  }

  lifecycle {
    postcondition {
      condition = local.node_detail_refreshable 
      error_message = "Node detail is not refreshable because balancer_ssh and bastion_ssh are both inactive if the balancer is enabled please activate balancer_ssh."
    }
  }
}

resource "ssh_resource" "node_detail" {
  for_each = local.topology

  triggers = {
    revision = random_uuid.node_detail.result
  }

  host         = aws_instance.bootstrap_node.private_ip
  bastion_host = var.balancer ? module.balancer[0].address : aws_instance.bastion.public_ip
  bastion_port = var.balancer ? module.balancer[0].ssh_port : local.ssh_port

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
    bastion_public_ip           = var.balancer ? module.balancer[0].address : aws_instance.bastion.public_ip
    bastion_port                = var.balancer ? module.balancer[0].ssh_port : local.ssh_port
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
    bastion_port        = self.input.bastion_port
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
    bastion_public_ip           = var.balancer ? module.balancer[0].address : aws_instance.bastion.public_ip
    bastion_port                = var.balancer ? module.balancer[0].ssh_port : local.ssh_port
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
    bastion_port        = self.input.bastion_port
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

  tags = {
    Name      = "${var.identifier}-instellar-nodes"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_nodes_outgoing_v4" {
  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Allow all outgoing traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name      = "${var.identifier}-nodes-outgoing-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_nodes_outgoing_v6" {
  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Allow all outgoing traffic"
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"

  tags = {
    Name      = "${var.identifier}-nodes-outgoing-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "cross_nodes" {
  security_group_id            = aws_security_group.nodes_firewall.id
  description                  = "Full Cross Node Communication"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.nodes_firewall.id

  tags = {
    Name      = "${var.identifier}-cross-nodes"
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
    Name      = "${var.identifier}-from-bastion"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_http_v4" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public http for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-http-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_http_v6" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public http for setup or cluster without network load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-http-v6"
    Blueprint = var.blueprint
  }
}


resource "aws_vpc_security_group_ingress_rule" "nodes_public_https_v4" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public https for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-https-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_https_v6" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public https for setup or cluster without network load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-https-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_lxd_v4" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public lxd for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-lxd-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_lxd_v6" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public lxd for setup or cluster without network load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-lxd-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_uplink_v4" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public uplink for setup or cluster without network load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 49152
  to_port           = 49152
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-uplink-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_public_uplink_v6" {
  count = var.publicly_accessible ? 1 : 0

  security_group_id = aws_security_group.nodes_firewall.id
  description       = "Enable public uplink for setup or cluster without network load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 49152
  to_port           = 49152
  ip_protocol       = "tcp"

  tags = {
    Name      = "${var.identifier}-public-uplink-v6"
    Blueprint = var.blueprint
  }
}
