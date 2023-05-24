output "cluster_address" {
  value = aws_instance.bootstrap_node.public_ip
}

output "trust_token" {
  value = ssh_resource.trust_token.result
}

output "region" {
  value = var.region
}