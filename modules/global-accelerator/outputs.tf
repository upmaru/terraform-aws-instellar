output "address" {
  description = "Address of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "name" {
  value = var.identifier
}