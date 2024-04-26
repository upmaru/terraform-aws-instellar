output "address" {
  description = "Address of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.dual_stack_dns_name
}

output "name" {
  value = var.identifier
}