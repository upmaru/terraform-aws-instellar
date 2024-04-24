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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_globalaccelerator_accelerator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_accelerator) | resource |
| [aws_globalaccelerator_endpoint_group.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [aws_globalaccelerator_endpoint_group.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [aws_globalaccelerator_endpoint_group.lxd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [aws_globalaccelerator_endpoint_group.uplink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_endpoint_group) | resource |
| [aws_globalaccelerator_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener) | resource |
| [aws_globalaccelerator_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener) | resource |
| [aws_globalaccelerator_listener.lxd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener) | resource |
| [aws_globalaccelerator_listener.uplink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_http_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_http_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_https_v4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_https_v6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_lxd_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_lxd_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_uplink_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nodes_uplink_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ip_ranges.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ip_ranges) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_balancer"></a> [balancer](#input\_balancer) | n/a | <pre>object({<br>    enabled = bool<br>    id      = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_blueprint"></a> [blueprint](#input\_blueprint) | Identifier of the blueprint | `string` | n/a | yes |
| <a name="input_bootstrap_node"></a> [bootstrap\_node](#input\_bootstrap\_node) | n/a | <pre>object({<br>    id        = string<br>    slug      = string<br>    public_ip = string<br>  })</pre> | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identiifer for global accelerator | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | n/a | <pre>list(object({<br>    id        = string<br>    slug      = string<br>    public_ip = string<br>  }))</pre> | n/a | yes |
| <a name="input_nodes_security_group_id"></a> [nodes\_security\_group\_id](#input\_nodes\_security\_group\_id) | Security group id for nodes | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for endpoint group | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->