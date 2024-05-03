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
  value = flatten([
    [for key, a in aws_lb_target_group_attachment.http : a.id],
    [for key, a in aws_lb_target_group_attachment.https : a.id],
    [for key, a in aws_lb_target_group_attachment.lxd : a.id],
    [for key, a in aws_lb_target_group_attachment.uplink : a.id]
  ])
}