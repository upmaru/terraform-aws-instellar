## Basic Usage

Create a terraform script `main.tf` with the following:

```hcl
variable "aws_access_key" {}
variable "aws_secret_key" {}

module "instellar" {
  source = "upmaru/instellar/aws"
  version = "0.3.6"

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
  cluster_name = "orion-exp"
  cluster_topology = [
    {id = 1, name = "apple", size = "c5a.large"},
    {id = 2, name = "watermelon", size = "c5a.large"}
  ]
  
  storage_size = 40

  # Name of key is from your aws console
  # you manually add this via the GUI
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
```

Create a file `.auto.tfvars` which should not be checked in with version control and add the credentials

```hcl
aws_access_key = "<your access key>"
aws_secret_key = "<your secret key>"
```

Simply run

```shell
terraform init
terraform plan
terraform apply
```

The example above will form a cluster with 3 nodes, one node will be called the `bootrap-node` this node will be used to co-ordinate and orchestrate the setup. With this configuration you will get 2 more nodes `apple` and `watermelon`. You can name the node anything you want.

If you wish to add a node into the cluster you can modify the `cluster_topology` variable.

```diff
cluster_topology = [
  {id = 1, name = "apple", size = "c5a.large"},
  {id = 2, name = "watermelon", size = "c5a.large"},
+ {id = 3, name = "orange", size = "t3.large"}
]
```

Then run `terraform apply` it will automatically scale your cluster up and add `orange` to the cluster. You can also selectively remove a node from the cluster. Once you've bootstrapped your cluster do not change the `id` since it is used to compute assignments to subnets, if you don't want your nodes replaced don't change the `id`.

```diff
cluster_topology = [
  {id = 1, name = "apple", size = "c5a.large"},
- {id = 2, name = "watermelon", size = "c5a.large"},
  {id = 3, name = "orange", size = "t3.large"}
]
```

Running `terraform apply` will gracefully remove `watermelon` from the cluster.

### Instance Type

You can specify the type of instance to use by specifying the size in the `cluster_topology`.

```hcl
cluster_topology = [
  {id = 1, name = "apple", size = "c5a.large"},
  {id = 2, name = "watermelon", size = "c5a.large"},
  {id = 3, name = "orange", size = "t3.large"}
]
```