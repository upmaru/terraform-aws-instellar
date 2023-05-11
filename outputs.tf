output "cluster_address" {
  value = "${aws_instance.bootstrap_node.public_ip}:8443"
}

output "trust_token" {
  value = ssh_resource.trust_token.result
}