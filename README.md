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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.3 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_balancer"></a> [balancer](#module\_balancer) | upmaru/instellar/aws//modules/balancer | ~> 0.9 |
| <a name="module_global_accelerator"></a> [global\_accelerator](#module\_global\_accelerator) | upmaru/instellar/aws//modules/global-accelerator | ~> 0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion_patch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nodes_patch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.bootstrap_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_key_pair.terraform_cloud](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_placement_group.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group) | resource |
| [aws_security_group.bastion_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.nodes_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_bastion_outgoing_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_bastion_outgoing_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_nodes_outgoing_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_nodes_outgoing_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cross_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_from_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_http_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_http_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_https_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_https_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_lxd_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_lxd_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_uplink_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_public_uplink_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [ssh_resource.cluster_join_token](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.node_detail](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.trust_token](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [terraform_data.bastion_cloudinit](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.reboot](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.removal](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [tls_private_key.bastion_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [tls_private_key.terraform_cloud](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_key_pair.terminal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/key_pair) | data source |
| [cloudinit_config.bastion](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [cloudinit_config.node](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture of the AMI | `string` | `"amd64"` | no |
| <a name="input_balancer"></a> [balancer](#input\_balancer) | Enable Load Balancer | `bool` | `false` | no |
| <a name="input_balancer_deletion_protection"></a> [balancer\_deletion\_protection](#input\_balancer\_deletion\_protection) | Enable balancer deletion protection | `bool` | `true` | no |
| <a name="input_balancer_ssh"></a> [balancer\_ssh](#input\_balancer\_ssh) | Enable SSH port on balancer | `bool` | `true` | no |
| <a name="input_bastion_size"></a> [bastion\_size](#input\_bastion\_size) | Bastion instance type? | `string` | `"t3a.micro"` | no |
| <a name="input_bastion_ssh"></a> [bastion\_ssh](#input\_bastion\_ssh) | Enable SSH port | `bool` | `true` | no |
| <a name="input_blueprint"></a> [blueprint](#input\_blueprint) | Identifier of the blueprint | `string` | n/a | yes |
| <a name="input_cluster_topology"></a> [cluster\_topology](#input\_cluster\_topology) | How many nodes do you want in your cluster? | <pre>list(object({<br>    id   = number<br>    name = string<br>    size = optional(string, "t3.medium")<br>  }))</pre> | `[]` | no |
| <a name="input_global_accelerator"></a> [global\_accelerator](#input\_global\_accelerator) | Enable Global Accelerator | `bool` | `false` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Name of your cluster | `string` | n/a | yes |
| <a name="input_network_dependencies"></a> [network\_dependencies](#input\_network\_dependencies) | value | `list` | `[]` | no |
| <a name="input_node_detail_revision"></a> [node\_detail\_revision](#input\_node\_detail\_revision) | The revision of the node detail | `number` | `1` | no |
| <a name="input_node_monitoring"></a> [node\_monitoring](#input\_node\_monitoring) | Enable / Disable detailed monitoring | `bool` | `false` | no |
| <a name="input_node_size"></a> [node\_size](#input\_node\_size) | Which instance type? | `string` | `"t3a.medium"` | no |
| <a name="input_protect_leader"></a> [protect\_leader](#input\_protect\_leader) | Protect the database leader node | `bool` | `true` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet ids to pass in if block type is compute | `list(string)` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Make the cluster publically accessible? If you use a load balancer this can be false. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | List of ssh key names | `list(string)` | `[]` | no |
| <a name="input_ssm"></a> [ssm](#input\_ssm) | Enable SSM | `bool` | `false` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | How much storage on your nodes? | `number` | `40` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Type of EBS Volume to use | `string` | `"gp3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id to pass in if block type is compute | `string` | n/a | yes |
| <a name="input_vpc_ip_range"></a> [vpc\_ip\_range](#input\_vpc\_ip\_range) | VPC ip range | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_balancer"></a> [balancer](#output\_balancer) | Load balancer details |
| <a name="output_bastion_access"></a> [bastion\_access](#output\_bastion\_access) | Bastion access output for passing into other modules |
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | Bastion security group id |
| <a name="output_bootstrap_node"></a> [bootstrap\_node](#output\_bootstrap\_node) | Bootstrap node details |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | Bootstrap node public ip |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Identifier of the cluster |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | Compute nodes details |
| <a name="output_nodes_iam_role"></a> [nodes\_iam\_role](#output\_nodes\_iam\_role) | IAM Role for nodes and bootstrap node |
| <a name="output_nodes_security_group_id"></a> [nodes\_security\_group\_id](#output\_nodes\_security\_group\_id) | Nodes security group id |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnet IDs |
| <a name="output_trust_token"></a> [trust\_token](#output\_trust\_token) | Trust token for the cluster |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC id |
<!-- END_TF_DOCS -->

