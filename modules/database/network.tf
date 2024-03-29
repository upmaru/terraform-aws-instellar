resource "aws_db_subnet_group" "this" {
  name        = var.identifier
  description = "Instellar ${var.engine} database subnet group"
  subnet_ids  = var.subnet_ids

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_security_group" "database" {
  name        = var.identifier
  description = "Instellar ${var.engine} database configuration"
  vpc_id      = var.vpc_id

  ingress {
    description     = "${var.engine} database access"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }

  tags = {
    Blueprint = var.blueprint
  }
}