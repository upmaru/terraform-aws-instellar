variable "aws_access_key" {}
variable "aws_secret_key" {}

module "instellar" {
  source = "../.."

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  cluster_name = "orion-exp"
  cluster_topology = [
    {id = 1, name = "apple"},
    {id = 3, name = "watermelon"}
  ]
  storage_size = 40
  ssh_keys = [
    "zack-studio",
    "zack-one-eight"
  ]
}