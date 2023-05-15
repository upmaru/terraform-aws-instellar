variable "aws_access_key" {}
variable "aws_secret_key" {}

module "instellar" {
  source = "../.."

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
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

output "trust_token" {
  value = module.instellar.trust_token
}

output "cluster_address" {
  value = module.instellar.cluster_address
}