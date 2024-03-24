resource "aws_security_group" "this" {
  name        = "${var.identifier}-balancer"
  description = "Allow inbound for serving http / https and opsmaru ports"
  vpc_id      = var.vpc_id

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_outgoing" {
  security_group_id            = aws_security_group.this.id
  description                  = "Allow all outgoing traffic"
  ip_protocol                  = "-1"
  referenced_security_group_id = var.nodes_security_group_id

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_v4" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public http v4 to load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_v6" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public http v6 to load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_v4" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public https v4 to load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_v6" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public https v6 to load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "lxd_v4" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public lxd v4 to load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "lxd_v6" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public lxd v6 to load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "uplink_v4" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public uplink v4 to load balancer"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 49152
  to_port           = 49152
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "uplink_v6" {
  security_group_id = aws_security_group.this.id
  description       = "Enable public uplink v6 to load balancer"
  cidr_ipv6         = "::/0"
  from_port         = 49152
  to_port           = 49152
  ip_protocol       = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_http" {
  security_group_id            = var.nodes_security_group_id
  description                  = "Enable load balancer traffic for http"
  referenced_security_group_id = aws_security_group.this.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_https" {
  security_group_id            = var.nodes_security_group_id
  description                  = "Enable load balancer traffic for https"
  referenced_security_group_id = aws_security_group.this.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_lxd" {
  security_group_id            = var.nodes_security_group_id
  description                  = "Enable load balancer traffic for lxd"
  referenced_security_group_id = aws_security_group.this.id
  from_port                    = 8443
  to_port                      = 8443
  ip_protocol                  = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodes_uplink" {
  security_group_id            = var.nodes_security_group_id
  description                  = "Enable load balancer traffic for uplink"
  referenced_security_group_id = aws_security_group.this.id
  from_port                    = 49152
  to_port                      = 49152
  ip_protocol                  = "tcp"

  tags = {
    Blueprint = var.blueprint
  }
}