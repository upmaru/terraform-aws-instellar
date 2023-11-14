<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | CA Cert identifier | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name to create | `string` | `"instellar"` | no |
| <a name="input_db_size"></a> [db\_size](#input\_db\_size) | Database instance size | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username | `string` | `"instellar"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Database deletion protection | `bool` | `true` | no |
| <a name="input_enable_performance_insight"></a> [enable\_performance\_insight](#input\_enable\_performance\_insight) | Enable performance insight | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Database instance name | `string` | n/a | yes |
| <a name="input_max_storage_size"></a> [max\_storage\_size](#input\_max\_storage\_size) | Database max storage size | `number` | `100` | no |
| <a name="input_port"></a> [port](#input\_port) | Database port | `number` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Database publically accessible | `bool` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Database security group ids | `list(string)` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Database skip final snapshot | `bool` | `false` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | Database storage size | `number` | `20` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Database storage type | `string` | `"gp3"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Database subnet ids | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Database VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The database address |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The database name |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The database endpoint |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | The database engine version |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | The database identifier |
| <a name="output_password"></a> [password](#output\_password) | The database master password |
| <a name="output_port"></a> [port](#output\_port) | The database port |
| <a name="output_username"></a> [username](#output\_username) | The database master username |
<!-- END_TF_DOCS -->