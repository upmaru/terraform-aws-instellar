variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  // replace with your cluster name
  cluster_name  = "pizza"
  provider_name = "aws"
}

module "bucket" {
  source = "../../modules/storage"

  bucket_name = local.cluster_name
}

module "primary_compute" {
  source = "../.."

  cluster_name = local.cluster_name
  node_size    = "t3a.medium"
  cluster_topology = [
    // replace name of node with anything you like
    // you can use 01, 02 also to keep it simple.
    { id = 1, name = "ham", size = "t3a.medium" },
    { id = 2, name = "bacon", size = "t3a.medium" },
  ]
  volume_type  = "gp3"
  storage_size = 40
  ssh_keys = [
    "zack-studio",
    "zack-one-eight"
  ]
}

module "postgresql" {
  source = "../../modules/database"

  identifier = "${local.cluster_name}-postgres-db"

  db_size        = "db.t3.small"
  db_name        = "instellardb"
  engine         = "postgres"
  engine_version = "15"
  port           = 5432

  db_username = "instellar"

  subnet_ids          = module.primary_compute.public_subnet_ids
  security_group_ids  = [module.primary_compute.nodes_security_group_id]
  vpc_id              = module.primary_compute.vpc_id
  deletion_protection = false
  skip_final_snapshot = true
}

variable "instellar_host" {}
variable "instellar_auth_token" {}

provider "instellar" {
  host       = var.instellar_host
  auth_token = var.instellar_auth_token
}

module "storage" {
  source  = "upmaru/bootstrap/instellar//modules/storage"
  version = "~> 0.4"

  bucket = module.bucket.name
  region = var.aws_region
  host   = module.bucket.host

  access_key = module.bucket.access_key_id
  secret_key = module.bucket.secret_access_key
}

module "compute_cluster" {
  source  = "upmaru/bootstrap/instellar"
  version = "~> 0.4"

  cluster_name    = local.cluster_name
  region          = var.aws_region
  provider_name   = local.provider_name
  uplink_channel  = "develop"
  cluster_address = module.primary_compute.cluster_address
  password_token  = module.primary_compute.trust_token

  bootstrap_node = module.primary_compute.bootstrap_node
  nodes          = module.primary_compute.nodes
}

module "postgresql_service" {
  source  = "upmaru/bootstrap/instellar//modules/service"
  version = "~> 0.4"

  slug           = module.postgresql.identifier
  provider_name  = local.provider_name
  driver         = "database/postgresql"
  driver_version = "15"
  cluster_ids    = [module.compute_cluster.cluster_id]
  channels       = ["develop", "master"]
  credential = {
    username = module.postgresql.username
    password = module.postgresql.password
    database = module.postgresql.db_name
    host     = module.postgresql.address
    port     = module.postgresql.port
  }
}