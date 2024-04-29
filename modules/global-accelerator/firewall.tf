data "aws_ip_ranges" "this" {
  regions  = ["global"]
  services = ["globalaccelerator"]
}

resource "aws_vpc_security_group_ingress_rule" "nodes_http_v4" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable http traffic from global accelerator ipv4"
  cidr_ipv4         = each.value

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-http-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_http_v6" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.ipv6_cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable http traffic from global accelerator ipv6"
  cidr_ipv6         = each.value

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-http-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_https_v4" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable https traffic from global accelerator ipv4"
  cidr_ipv4         = each.value

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-https-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_https_v6" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.ipv6_cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable https traffic from global accelerator ipv6"
  cidr_ipv6         = each.value

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-https-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_uplink_ipv4" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable uplink traffic from global accelerator ipv4"
  cidr_ipv4         = each.value

  from_port   = 49152
  to_port     = 49152
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-uplink-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_uplink_ipv6" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.ipv6_cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable uplink traffic from global accelerator ipv6"
  cidr_ipv6         = each.value

  from_port   = 49152
  to_port     = 49152
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-uplink-v6"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_lxd_ipv4" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable lxd traffic from global accelerator ipv4"
  cidr_ipv4         = each.value

  from_port   = 8443
  to_port     = 8443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-lxd-v4"
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_lxd_ipv6" {
  for_each = var.balancer.enabled ? [] : toset(data.aws_ip_ranges.this.ipv6_cidr_blocks)

  security_group_id = var.nodes_security_group_id
  description       = "Enable lxd traffic from global accelerator ipv6"
  cidr_ipv6         = each.value

  from_port   = 8443
  to_port     = 8443
  ip_protocol = "tcp"

  tags = {
    Name      = "${var.identifier}-global-accelerator-lxd-v4"
    Blueprint = var.blueprint
  }
}