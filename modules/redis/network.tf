resource "aws_elasticache_subnet_group" "this" {
  name        = var.identifier
  description = "Instellar Redis subnet group"
  subnet_ids  = var.subnet_ids

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_security_group" "this" {
  name        = var.identifier
  description = "Instellar Redis configuration"
  vpc_id      = var.vpc_id

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = toset(var.security_group_ids)

  security_group_id            = aws_security_group.this.id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.key

  tags = {
    Name      = "${var.identifier}-ingress"
    Blueprint = var.blueprint
  }
}