<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secret"></a> [secret](#module\_secret) | upmaru/instellar/aws//modules/secret | ~> 0.8 |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_uuid.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_at_rest_encryption"></a> [at\_rest\_encryption](#input\_at\_rest\_encryption) | Enable / Disable at rest encryption | `bool` | `true` | no |
| <a name="input_blueprint"></a> [blueprint](#input\_blueprint) | Blueprint name | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version number of Redis to be used | `string` | `"7.0"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifier of the cluster | `string` | n/a | yes |
| <a name="input_manage_credential_with_secret"></a> [manage\_credential\_with\_secret](#input\_manage\_credential\_with\_secret) | Enable / Disable auth token management with secret manager | `bool` | `false` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | The compute and memory capacity of the nodes | `string` | `"cache.t3.micro"` | no |
| <a name="input_nodes_iam_roles"></a> [nodes\_iam\_roles](#input\_nodes\_iam\_roles) | The IAM role to attach the policy to | <pre>list(object({<br>    name = string<br>    id   = string<br>  }))</pre> | n/a | yes |
| <a name="input_num_cache_clusters"></a> [num\_cache\_clusters](#input\_num\_cache\_clusters) | Number of cache replicas | `number` | `1` | no |
| <a name="input_password_revision"></a> [password\_revision](#input\_password\_revision) | Password revision | `number` | `1` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the cache accepts connections | `number` | `6379` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC subnet IDs | `list(string)` | n/a | yes |
| <a name="input_transit_encryption"></a> [transit\_encryption](#input\_transit\_encryption) | Enable / Disable transit encryption | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->