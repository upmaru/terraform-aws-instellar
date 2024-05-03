output "address" {
  description = "Address name from the load balancer"
  value       = aws_lb.this.dns_name
}

output "name" {
  value = var.identifier
}

output "ssh_port" {
  description = "The bastion ssh port"
  value       = local.ssh_port
}

output "arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "dependencies" {
  description = "Dependencies of load balancer"
  value = [
    aws_vpc_security_group_ingress_rule.nodes_http.security_group_rule_id,
    aws_vpc_security_group_ingress_rule.nodes_https.security_group_rule_id,
    aws_vpc_security_group_ingress_rule.nodes_lxd.security_group_rule_id,
    aws_vpc_security_group_ingress_rule.nodes_uplink.security_group_rule_id
  ]
}