data "aws_security_groups" "this" {
  filter {
    name   = "group-name"
    values = ["GlobalAccelerator"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_http" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_security_groups.this.ids)

  security_group_id            = var.nodes_security_group_id
  description                  = "Enable http traffic from global accelerator"
  referenced_security_group_id = each.value

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-http"
    Blueprint = var.blueprint
  }
}


resource "aws_vpc_security_group_ingress_rule" "nodes_https" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_security_groups.this.ids)

  security_group_id            = var.nodes_security_group_id
  description                  = "Enable https traffic from global accelerator"
  referenced_security_group_id = each.value

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-https"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_uplink" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_security_groups.this.ids)

  security_group_id            = var.nodes_security_group_id
  description                  = "Enable uplink traffic from global accelerator"
  referenced_security_group_id = each.value

  from_port   = 49152
  to_port     = 49152
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-uplink"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_lxd" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_security_groups.this.ids)

  security_group_id            = var.nodes_security_group_id
  description                  = "Enable lxd traffic from global accelerator ipv4"
  referenced_security_group_id = each.value

  from_port   = 8443
  to_port     = 8443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-lxd"
    Blueprint = var.blueprint
  }
}