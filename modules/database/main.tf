locals {
  is_replica = var.replicate_source_db != null
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# tfsec:ignore:aws-rds-enable-iam-auth
resource "aws_db_instance" "this" {
  identifier = "${var.identifier}-${var.engine}"

  availability_zone = var.availability_zone

  db_name            = var.db_name
  engine             = var.engine
  engine_version     = var.engine_version
  instance_class     = var.db_size
  username           = !local.is_replica ? var.db_username : null
  password           = !local.is_replica && var.manage_master_user_password ? null : random_password.password.result
  port               = var.port
  ca_cert_identifier = var.ca_cert_identifier

  manage_master_user_password = !local.is_replica && var.manage_master_user_password ? var.manage_master_user_password : null

  replicate_source_db = var.replicate_source_db

  allocated_storage     = var.storage_size
  max_allocated_storage = var.max_storage_size
  storage_type          = var.storage_type

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.database.id]

  performance_insights_enabled = var.enable_performance_insight

  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az

  final_snapshot_identifier = "${var.identifier}-snapshot"

  publicly_accessible = var.publicly_accessible
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  apply_immediately   = var.apply_immediately

  tags = {
    Blueprint = var.blueprint
  }
}