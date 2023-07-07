resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  db_name        = var.db_name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.db_size
  username       = var.db_username
  password       = random_password.password.result

  allocated_storage     = var.storage_size
  max_allocated_storage = var.max_storage_size

  db_subnet_group_name = aws_db_subnet_group.this.name

  publically_accessible = var.publically_accessible
  deletion_protection = var.deletion_protection
}