resource "aws_db_subnet_group" "this" {
  name        = var.identifier
  description = "Instellar ${var.engine} database subnet group"
  subnet_ids  = var.subnet_ids
}

resource "aws_security_group" "database" {
  name        = var.identifier
  description = "Instellar ${var.engine} database configuration"
  vpc_id      = var.vpc_id

  ingress {
    description     = "${var.engine} database access"
    from_port       = aws_db_instance.this.port
    to_port         = aws_db_instance.this.port
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }
}