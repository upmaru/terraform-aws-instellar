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