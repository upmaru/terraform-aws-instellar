variable "aws_access_key" {}
variable "aws_secret_key" {}

locals {
  cluster_name = "pizza"
}

module "compute" {
  source = "../.."

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  cluster_name = local.cluster_name
  node_size    = "t3a.medium"
  cluster_topology = [
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

variable "instellar_auth_token" {}
module "instellar" {
  source  = "upmaru/bootstrap/instellar"
  version = "0.2.2"

  host            = "https://staging-web.instellar.app"
  auth_token      = var.instellar_auth_token
  cluster_name    = local.cluster_name
  region          = module.compute.region
  provider_name   = "aws"
  cluster_address = module.compute.cluster_address
  password_token  = module.compute.trust_token

  uplink_channel = "develop"
}
