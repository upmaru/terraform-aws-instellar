output "cluster_address" {
  description = "Bootstrap node public ip"
  value       = aws_instance.bootstrap_node.public_ip
}

output "identifier" {
  description = "Identifier of the cluster"
  value       = var.identifier
}

output "trust_token" {
  description = "Trust token for the cluster"
  value       = ssh_resource.trust_token.result
}

output "bootstrap_node" {
  description = "Bootstrap node details"
  value = {
    slug      = aws_instance.bootstrap_node.tags.Name
    public_ip = aws_instance.bootstrap_node.public_ip
    id        = aws_instance.bootstrap_node.id
  }
}

output "bastion_access" {
  description = "Bastion access output for passing into other modules"

  value = {
    user         = local.user
    host         = aws_instance.bastion.public_ip
    port         = local.ssh_port
    private_key  = tls_private_key.terraform_cloud.private_key_openssh
    architecture = var.ami_architecture
  }

  sensitive = true
}

output "nodes" {
  description = "Compute nodes details"
  value = [
    for key, node in aws_instance.nodes :
    {
      slug      = node.tags.Name
      public_ip = node.public_ip
      id        = node.id
    }
  ]
}

output "nodes_iam_role" {
  description = "IAM Role for nodes and bootstrap node"
  value = {
    name = aws_iam_role.nodes.name
    id   = aws_iam_role.nodes.id
  }
}

output "balancer" {
  description = "Load balancer details"
  value = {
    enabled = var.balancer
    name    = var.balancer ? module.balancer[0].name : null
    address = var.balancer ? module.balancer[0].address : null
  }
}

output "nodes_security_group_id" {
  description = "Nodes security group id"
  value       = aws_security_group.nodes_firewall.id
}

output "bastion_security_group_id" {
  description = "Bastion security group id"
  value       = aws_security_group.bastion_firewall.id
}

output "vpc_id" {
  description = "VPC id"
  value       = var.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = var.public_subnet_ids
}