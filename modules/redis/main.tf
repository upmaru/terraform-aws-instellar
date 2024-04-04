resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!&#$^<>-"

  keepers = {
    password_revision = var.password_revision
  }
}

resource "random_uuid" "this" {}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.identifier
  description          = "${var.identifier} redis replication group"
  num_cache_clusters   = var.num_cache_clusters
  node_type            = var.node_type
  port                 = var.port
  engine               = "redis"
  engine_version       = var.engine_version

  at_rest_encryption_enabled = var.at_rest_encryption

  auth_token                 = random_password.password.result
  transit_encryption_enabled = var.transit_encryption

  final_snapshot_identifier = "${var.identifier}-snapshot"

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Name      = var.identifier
    Blueprint = var.blueprint
  }
}

module "secret" {
  count = var.manage_credential_with_secret ? 1 : 0

  source  = "upmaru/instellar/aws//modules/secret"
  version = "~> 0.8"

  blueprint   = var.blueprint
  key         = "${var.identifier}/redis/${random_uuid.this.result}"
  description = "Store ${var.identifier} redis credential"
  value = jsonencode({
    endpoint        = aws_elasticache_replication_group.this.primary_endpoint_address
    reader_endpoint = aws_elasticache_replication_group.this.reader_endpoint_address
    port            = var.port
    password        = random_password.password.result
  })
  nodes_iam_roles = var.nodes_iam_roles
}

