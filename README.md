# Terraform AWS Module for Instellar

This module automatically forms LXD cluster on amazon AWS. This terraform module will do the following:

- [x] Setup networking
- [x] Setup multi az public subnet
- [x] Setup bastion node
- [x] Setup compute instances
- [x] Setup Private Key access
- [x] Automatically form a cluster
- [x] Destroy a cluster
- [x] Enable removal of specific nodes gracefully
- [x] Protect against `database-leader` deletion

These functionality come together to enable the user to fully manage LXD cluster using IaC (infrastructure as code)

## Basic Usage

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

### Instance Type

You can specify the type of instance to use by specifying the size in the `cluster_topology`.

```hcl
cluster_topology = [
  {id = 1, name = "apple", size = "c5a.large"},
  {id = 2, name = "watermelon", size = "c5a.large"},
  {id = 3, name = "orange", size = "t3.large"}
]
```

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.66.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.66.1 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.2 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.6.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/instance) | resource |
| [aws_instance.bootstrap_node](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/instance) | resource |
| [aws_instance.nodes](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/instance) | resource |
| [aws_internet_gateway.cluster_gw](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/internet_gateway) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/key_pair) | resource |
| [aws_key_pair.terraform_cloud](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/key_pair) | resource |
| [aws_placement_group.nodes](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/placement_group) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/route_table) | resource |
| [aws_route_table_association.public_subnet_assoc](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/route_table_association) | resource |
| [aws_security_group.bastion_firewall](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/security_group) | resource |
| [aws_security_group.nodes_firewall](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/security_group) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/subnet) | resource |
| [aws_vpc.cluster_vpc](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/resources/vpc) | resource |
| [ssh_resource.cluster_join_token](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.node_detail](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [terraform_data.reboot](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.removal](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [tls_private_key.bastion_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.terraform_cloud](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/data-sources/ami) | data source |
| [aws_key_pair.terminal](https://registry.terraform.io/providers/hashicorp/aws/4.66.1/docs/data-sources/key_pair) | data source |
| [cloudinit_config.bastion](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.node](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | AWS Access Key | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability Zones | `list(string)` | <pre>[<br>  "us-west-2a",<br>  "us-west-2b",<br>  "us-west-2c"<br>]</pre> | no |
| <a name="input_bastion_size"></a> [bastion\_size](#input\_bastion\_size) | Bastion instance type? | `string` | `"t2.micro"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of your cluster | `string` | n/a | yes |
| <a name="input_cluster_topology"></a> [cluster\_topology](#input\_cluster\_topology) | How many nodes do you want in your cluster? | <pre>list(object({<br>    id   = number<br>    name = string<br>    size = optional(string, "t3.medium")<br>  }))</pre> | `[]` | no |
| <a name="input_node_size"></a> [node\_size](#input\_node\_size) | Which instance type? | `string` | `"t3.medium"` | no |
| <a name="input_protect_leader"></a> [protect\_leader](#input\_protect\_leader) | Protect the database leader node | `bool` | `true` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | Public Subnet CIDR values | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region you want to use | `string` | `"us-west-2"` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | AWS Secret Key | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | List of ssh key names | `list(string)` | `[]` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | How much storage on your nodes? | `number` | `40` | no |
| <a name="input_vpc_ip_range"></a> [vpc\_ip\_range](#input\_vpc\_ip\_range) | VPC ip range | `string` | `"10.0.0.0/16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

