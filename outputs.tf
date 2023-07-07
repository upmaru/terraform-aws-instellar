output "cluster_address" {
  value = aws_instance.bootstrap_node.public_ip
}

output "trust_token" {
  value = ssh_resource.trust_token.result
}

output "region" {
  value = var.region
}

output "bootstrap_node" {
  value = {
    slug      = aws_instance.bootstrap_node.tags.Name
    public_ip = aws_instance.bootstrap_node.public_ip
  }
}

output "nodes" {
  value = [
    for key, node in aws_instance.nodes :
    {
      slug      = node.tags.Name
      public_ip = node.public_ip
    }
  ]
}

output "nodes_security_group_id" {
  value = aws_security_group.nodes_firewall.id
} 

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}