provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

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
}