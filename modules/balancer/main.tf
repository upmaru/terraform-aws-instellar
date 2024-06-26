locals {
  ssh_port = 2348
  topology = {
    for index, node in concat(var.nodes, [var.bootstrap_node]) :
    node.slug => node
  }
}

resource "aws_lb" "this" {
  name               = "${var.identifier}-balancer"
  load_balancer_type = "network"
  security_groups    = [aws_security_group.this.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.deletion_protection

  tags = {
    Name      = "${var.identifier}-balancer"
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group" "ssh" {
  name     = "${var.identifier}-target-group-ssh"
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = 22
    interval = 10
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group_attachment" "ssh" {
  target_group_arn = aws_lb_target_group.ssh.arn
  target_id        = var.bastion_node.id
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.this.arn
  port              = local.ssh_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh.arn
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group" "http" {
  name     = "${var.identifier}-target-group-http"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = 80
    interval = 10
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group_attachment" "http" {
  for_each         = local.topology
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = each.value.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group" "https" {
  name     = "${var.identifier}-target-group-https"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = 443
    interval = 10
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group_attachment" "https" {
  for_each         = local.topology
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = each.value.id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group" "lxd" {
  name     = "${var.identifier}-target-group-lxd"
  port     = 8443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = 8443
    interval = 10
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group_attachment" "lxd" {
  for_each         = local.topology
  target_group_arn = aws_lb_target_group.lxd.arn
  target_id        = each.value.id
}

resource "aws_lb_listener" "lxd" {
  load_balancer_arn = aws_lb.this.arn
  port              = "8443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lxd.arn
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group" "uplink" {
  name     = "${var.identifier}-target-group-uplink"
  port     = 49152
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = 49152
    interval = 10
  }

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_lb_target_group_attachment" "uplink" {
  for_each         = local.topology
  target_group_arn = aws_lb_target_group.uplink.arn
  target_id        = each.value.id
}

resource "aws_lb_listener" "uplink" {
  load_balancer_arn = aws_lb.this.arn
  port              = "49152"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uplink.arn
  }

  tags = {
    Blueprint = var.blueprint
  }
}
