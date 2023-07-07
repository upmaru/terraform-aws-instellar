resource "aws_db_subnet_group" "this" {
  name       = var.identifier
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "database" {
  name        = "${var.cluster_name}-instellar-${var.engine}"
  description = "Instellar ${var.engine} database configuration"
  vpc_id      = var.vpc_id

  ingress {
    description     = "${var.engine} database access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }
}