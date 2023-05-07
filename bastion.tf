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

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_size
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.bastion_firewall.id]
  user_data_base64       = data.cloudinit_config.bastion.rendered

  connection {
    type        = "ssh"
    user        = "ubuntu"
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
    Name = "${var.cluster_name}-bastion"
  }
}