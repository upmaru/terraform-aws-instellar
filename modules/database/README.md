<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secret"></a> [secret](#module\_secret) | upmaru/instellar/aws//modules/secret | ~> 0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_uuid.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Database availability zone | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Backup retention days | `number` | `5` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Database backup window, do not overlap with maintenance\_window | `string` | `"09:46-10:16"` | no |
| <a name="input_blueprint"></a> [blueprint](#input\_blueprint) | Blueprint name | `string` | n/a | yes |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | CA Cert identifier | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name to create | `string` | `"instellar"` | no |
| <a name="input_db_password_revision"></a> [db\_password\_revision](#input\_db\_password\_revision) | Database password revision | `number` | `1` | no |
| <a name="input_db_size"></a> [db\_size](#input\_db\_size) | Database instance size | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username | `string` | `"instellar"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Database deletion protection | `bool` | `true` | no |
| <a name="input_enable_performance_insight"></a> [enable\_performance\_insight](#input\_enable\_performance\_insight) | Enable performance insight | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Database instance name | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Database maintenance window | `string` | `"Sun:00:00-Sun:03:00"` | no |
| <a name="input_manage_credential_with_secret"></a> [manage\_credential\_with\_secret](#input\_manage\_credential\_with\_secret) | Manage credentials with secret | `bool` | `false` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Manage master user password | `bool` | `false` | no |
| <a name="input_max_storage_size"></a> [max\_storage\_size](#input\_max\_storage\_size) | Database max storage size | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Enable multi AZ | `bool` | `false` | no |
| <a name="input_nodes_iam_roles"></a> [nodes\_iam\_roles](#input\_nodes\_iam\_roles) | The IAM role to attach the policy to | <pre>list(<br>    object({<br>      name = string<br>      id   = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Database port | `number` | n/a | yes |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Database publicly accessible | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Database region | `string` | n/a | yes |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Replicate source database | `string` | `null` | no |
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
| <a name="output_certificate_url"></a> [certificate\_url](#output\_certificate\_url) | The certificate url for using with the database. |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The database name |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The database endpoint |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | The database engine version |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | The database identifier |
| <a name="output_password"></a> [password](#output\_password) | The database master password |
| <a name="output_port"></a> [port](#output\_port) | The database port |
| <a name="output_username"></a> [username](#output\_username) | The database master username |
<!-- END_TF_DOCS -->