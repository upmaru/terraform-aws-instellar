variable "identifier" {}

variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "public_subnet_cidrs" {}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  // replace with your cluster name
  provider_name = "aws"
}

module "bucket" {
  source = "../../modules/storage"

  bucket_name = var.identifier
}

module "networking_primary" {
  source = "../../modules/network"

  identifier = var.identifier
  region     = var.aws_region
}

module "compute_primary" {
  source = "../.."

  identifier = "${var.identifier}-a"

  vpc_id               = module.networking_primary.vpc_id
  public_subnet_ids    = module.networking_primary.public_subnet_ids
  vpc_ip_range         = module.networking_primary.vpc_ip_range
  network_dependencies = module.networking_primary.dependencies

  node_size = "t3a.medium"
  cluster_topology = [
    // replace name of node with anything you like
    // you can use 01, 02 also to keep it simple.
    { id = 1, name = "01", size = "t3a.medium" },
    { id = 2, name = "02", size = "t3a.medium" },
  ]
  volume_type  = "gp3"
  storage_size = 40
  ssh_keys = [
    "zack-studio"
  ]
}

module "compute_secondary" {
  source = "../.."

  identifier = "${var.identifier}-b"

  vpc_id               = module.networking_primary.vpc_id
  public_subnet_ids    = module.networking_primary.public_subnet_ids
  vpc_ip_range         = module.networking_primary.vpc_ip_range
  network_dependencies = module.networking_primary.dependencies

  node_size = "t3a.medium"
  cluster_topology = [
    // replace name of node with anything you like
    // you can use 01, 02 also to keep it simple.
    { id = 1, name = "01", size = "t3a.medium" },
    { id = 2, name = "02", size = "t3a.medium" },
  ]
  volume_type  = "gp3"
  storage_size = 40
  ssh_keys = [
    "zack-studio"
  ]
}

module "postgresql" {
  source = "../../modules/database"

  identifier = "${var.identifier}-postgres-db"
  region     = var.aws_region

  db_size        = "db.t3.small"
  db_name        = "instellardb"
  engine         = "postgres"
  engine_version = "15"
  port           = 5432

  db_username = "instellar"

  subnet_ids = module.networking_primary.public_subnet_ids

  security_group_ids = [
    module.compute_primary.nodes_security_group_id,
    module.compute_secondary.nodes_security_group_id
  ]

  vpc_id              = module.networking_primary.vpc_id
  deletion_protection = false
  skip_final_snapshot = true
}

module "bucket_generator" {
  source = "../../modules/bucket"

  identifier = var.identifier
  region     = var.aws_region
}

variable "instellar_host" {}
variable "instellar_auth_token" {}

provider "instellar" {
  host       = var.instellar_host
  auth_token = var.instellar_auth_token
}

module "storage" {
  source  = "upmaru/bootstrap/instellar//modules/storage"
  version = "~> 0.5"

  bucket = module.bucket.name
  region = var.aws_region
  host   = module.bucket.host

  access_key = module.bucket.access_key_id
  secret_key = module.bucket.secret_access_key
}

module "primary_cluster" {
  source  = "upmaru/bootstrap/instellar"
  version = "~> 0.5"

  cluster_name    = module.compute_primary.identifier
  region          = var.aws_region
  provider_name   = local.provider_name
  uplink_channel  = "develop"
  cluster_address = module.compute_primary.cluster_address
  password_token  = module.compute_primary.trust_token

  bootstrap_node = module.compute_primary.bootstrap_node
  nodes          = module.compute_primary.nodes
}

module "secondary_cluster" {
  source  = "upmaru/bootstrap/instellar"
  version = "~> 0.5"

  cluster_name    = module.compute_secondary.identifier
  region          = var.aws_region
  provider_name   = local.provider_name
  uplink_channel  = "develop"
  cluster_address = module.compute_secondary.cluster_address
  password_token  = module.compute_secondary.trust_token

  bootstrap_node = module.compute_secondary.bootstrap_node
  nodes          = module.compute_secondary.nodes
}


module "postgresql_service" {
  source  = "upmaru/bootstrap/instellar//modules/service"
  version = "~> 0.5"

  slug           = module.postgresql.identifier
  provider_name  = local.provider_name
  driver         = "database/postgresql"
  driver_version = "15"

  cluster_ids = [
    module.primary_cluster.cluster_id,
    module.secondary_cluster.cluster_id
  ]

  channels    = ["develop", "master"]
  certificate = module.postgresql.certificate_url

  credential = {
    username = module.postgresql.username
    password = module.postgresql.password
    resource = module.postgresql.db_name
    host     = module.postgresql.address
    port     = module.postgresql.port
    secure   = true
  }
}

module "bucket_service" {
  source  = "upmaru/bootstrap/instellar//modules/service"
  version = "~> 0.5"

  slug           = module.bucket_generator.identifier
  provider_name  = local.provider_name
  driver         = "bucket/aws-s3"
  driver_version = "1"

  cluster_ids = [
    module.primary_cluster.cluster_id,
    module.secondary_cluster.cluster_id
  ]

  channels = ["develop", "master", "main"]

  credential = {
    username = module.bucket_generator.access_key_id
    password = module.bucket_generator.secret_access_key
    resource = module.bucket_generator.region
    host     = module.bucket_generator.host
    port     = 443
    secure   = true
  }
}
