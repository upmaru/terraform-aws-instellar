locals {
  is_replica  = var.replicate_source_db != null
  policy_name = var.manage_master_user_password ? replace(title(var.identifier), "-", "") : null
}

resource "random_password" "password" {
  keepers = {
    revision = var.db_password_revision
  }

  length  = 16
  special = false
}

resource "random_uuid" "this" {}

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

module "secret" {
  count = var.manage_credential_with_secret ? 1 : 0

  source  = "upmaru/instellar/aws//modules/secret"
  version = "~> 0.8"

  blueprint   = var.blueprint
  key         = "${var.identifier}/database/${random_uuid.this.result}"
  description = "Store ${var.identifier} database credential"
  value = jsonencode({
    engine             = var.engine
    database           = var.db_name
    port               = var.port
    username           = var.db_username
    password           = var.manage_master_user_password ? null : random_password.password.result
    endpoint           = aws_db_instance.this.endpoint
    password_secret_id = var.manage_master_user_password ? aws_db_instance.this.master_user_secret[0].secret_arn : null
  })
  nodes_iam_roles = var.nodes_iam_roles
}
