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
    aws_lb_listener.http.id,
    aws_lb_listener.https.id,
    aws_lb_listener.lxd.id,
    aws_lb_listener.uplink.id
  ]
}