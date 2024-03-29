data "aws_key_pair" "terminal" {
  count              = length(var.ssh_keys)
  key_name           = element(var.ssh_keys, count.index)
  include_public_key = true
}

data "cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yml.tpl", {
      ssh_keys = concat(data.aws_key_pair.terminal[*].public_key, [tls_private_key.terraform_cloud.public_key_openssh])
    })
  }
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.identifier}-bastion-profile"
  role = aws_iam_role.bastion.name

  tags = {
    Blueprint = var.blueprint
  }
}

resource "terraform_data" "bastion_cloudinit" {
  input = data.cloudinit_config.bastion.rendered
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_size
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.bastion_firewall.id]
  user_data_base64       = data.cloudinit_config.bastion.rendered

  iam_instance_profile = aws_iam_instance_profile.bastion.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  connection {
    type        = "ssh"
    user        = local.user
    host        = self.public_ip
    private_key = tls_private_key.terraform_cloud.private_key_openssh
  }

  provisioner "file" {
    content     = tls_private_key.bastion_key.private_key_openssh
    destination = "/home/ubuntu/.ssh/id_ed25519"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_ed25519"
    ]
  }

  tags = {
    Name      = "${var.identifier}-bastion"
    Blueprint = var.blueprint
  }

  lifecycle {
    ignore_changes = [
      ami
    ]

    replace_triggered_by = [
      terraform_data.bastion_cloudinit
    ]
  }
}

resource "aws_security_group" "bastion_firewall" {
  name        = "${var.identifier}-instellar-bastion"
  description = "Instellar Bastion Configuration"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "${var.identifier}-bastion-firewall"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_outgoing_v4" {
  security_group_id = aws_security_group.bastion_firewall.id
  description       = "Enable all outgoing traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name      = "${var.identifier}-bastion-outgoing-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_outgoing_v6" {
  security_group_id = aws_security_group.bastion_firewall.id
  description       = "Enable all outgoing traffic"
  ip_protocol       = "-1"
  cidr_ipv6         = "::/0"

  tags = {
    Name      = "${var.identifier}-bastion-outgoing-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  count = var.bastion_ssh ? 1 : 0

  security_group_id = aws_security_group.bastion_firewall.id
  description       = "Enable ssh traffic"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name      = "${var.identifier}-public-ssh"
    Blueprint = var.blueprint
  }
}