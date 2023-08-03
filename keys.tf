resource "tls_private_key" "terraform_cloud" {
  algorithm = "ED25519"
}

resource "tls_private_key" "bastion_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "terraform_cloud" {
  key_name   = "${var.identifier}-terraform-cloud"
  public_key = tls_private_key.terraform_cloud.public_key_openssh
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.identifier}-bastion"
  public_key = tls_private_key.bastion_key.public_key_openssh
}