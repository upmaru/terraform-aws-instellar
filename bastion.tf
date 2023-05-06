resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_size
  subnet_id              = aws_subnet.cluster_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_firewall.id]

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}