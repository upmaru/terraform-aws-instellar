# Terraform AWS Module for Instellar

This module automatically forms LXD cluster on amazon AWS. This terraform module will do the following:

- [x] Setup networking
- [x] Setup bastion node
- [x] Setup compute instances
- [x] Setup Private Key access
- [x] Automatically form a cluster
- [x] Destroy a cluster
- [x] Enable removal of specific nodes gracefully
- [x] Protect against `database-leader` deletion

These functionality come together to enable the user to fully manage LXD cluster using IaC (infrastructure as code)

## How to Use

Create a terraform script `main.tf` with the following:

```hcl
variable "aws_access_key" {}
variable "aws_secret_key" {}

module "instellar" {
  source = "upmaru/instellar/aws"
  version = "0.3.0"

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  cluster_name = "orion-exp"
  cluster_topology = [
    {id = 1, name = "apple"},
    {id = 2, name = "watermelon"}
  ]
  
  storage_size = 40

  # Name of key is from your aws console
  # you manually add this via the GUI
  ssh_keys = [
    "zack-studio",
    "zack-one-eight"
  ]
}
```

Create a file `.auto.tfvars` which should not be checked in with version control and add the credentials

```hcl
aws_access_key = "<your access key>"
aws_secret_key = "<your secret key>"
```

Simply run

```shell
terraform plan
terraform apply
```

The example above will form a cluster with 3 nodes, one node will be called the `bootrap-node` this node will be used to co-ordinate and orchestrate the setup. With this configuration you will get 2 more nodes `apple` and `watermelon`. You can name the node anything you want.

If you wish to add a node into the cluster you can modify the `cluster_topology` variable.

```diff
cluster_topology = [
  {id = 1, name = "apple"},
  {id = 2, name = "watermelon"},
+ {id = 3, name = "orange"}
]
```

Then run `terraform apply` it will automatically scale your cluster up and add `orange` to the cluster. You can also selectively remove a node from the cluster.

```diff
cluster_topology = [
  {id = 1, name = "apple"},
- {id = 2, name = "watermelon"},
  {id = 3, name = "orange"}
]
```

Running `terraform apply` will gracefully remove `watermelon` from the cluster.
