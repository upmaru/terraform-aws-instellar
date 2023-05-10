variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cluster_name" {}
variable "node_size" {}

module "instellar" {
  source = "../.."

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  cluster_name = "fruits"
  cluster_topology = [
    {id = 1, name = "apple"},
    {id = 2, name = "watermelon"}
  ]
  storage_size = 40
  ssh_keys = [
    "zack-studio",
    "zack-one-eight"
  ]
}