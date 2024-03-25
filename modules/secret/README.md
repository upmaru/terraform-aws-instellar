<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blueprint"></a> [blueprint](#input\_blueprint) | Identifier of the blueprint | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the secret | `string` | n/a | yes |
| <a name="input_key"></a> [key](#input\_key) | Key for the secret | `string` | n/a | yes |
| <a name="input_nodes_iam_role"></a> [nodes\_iam\_role](#input\_nodes\_iam\_role) | The IAM role to attach the policy to | <pre>object({<br>    name = string<br>    id   = string<br>  })</pre> | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | The value of the secret | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->