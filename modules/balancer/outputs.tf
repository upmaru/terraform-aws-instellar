output "dns_name" {
  description = "DNS name from the load balancer"
  value       = aws_lb.this.dns_name
}