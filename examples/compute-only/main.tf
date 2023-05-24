variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instellar_auth_token" {}

module "instellar" {
  source = "../.."

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  instellar_auth_token = var.instellar_auth_token
  cluster_name = "pizza"
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