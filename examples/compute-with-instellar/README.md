## Basic Usage

Create a terraform script `main.tf` with the following:

```hcl
variable "aws_access_key" {}
variable "aws_secret_key" {}

locals {
  // replace with your cluster name
  cluster_name = "pizza"
}

module "compute" {
  source = "upmaru/instellar/aws"
  version = "0.4.3"

  access_key   = var.aws_access_key
  secret_key   = var.aws_secret_key
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

variable "instellar_auth_token" {}

module "instellar" {
  source  = "upmaru/bootstrap/instellar"
  version = "0.3.1"

  host            = "https://staging-web.instellar.app"
  auth_token      = var.instellar_auth_token
  cluster_name    = local.cluster_name
  region          = module.compute.region
  provider_name   = "aws"
  cluster_address = module.compute.cluster_address
  password_token  = module.compute.trust_token

  uplink_channel = "develop"

  bootstrap_node = module.compute.bootstrap_node
  nodes          = module.compute.nodes
}
```

Create a file `.auto.tfvars` which should not be checked in with version control and add the credentials

```hcl
aws_access_key = "<your access key>"
aws_secret_key = "<your secret key>"
instellar_auth_key = "<retrieve from instellar dashboard>"
```

Simply run

```shell
terraform init
terraform plan
terraform apply
```

This will automatically form a cluster and add the resources to be managed by instellar.

## Changing Topology

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

