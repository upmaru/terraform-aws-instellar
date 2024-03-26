output "dns_name" {
  description = "DNS name from the load balancer"
  value       = aws_lb.this.dns_name
}

output "bastion_ssh_port" {
  description = "The bastion ssh port"
  value       = var.bastion_ssh_port
}