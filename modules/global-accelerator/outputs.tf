output "address" {
  description = "Address of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "name" {
  value = var.identifier
}

output "dependencies" {
  description = "Dependencies of Global Accelerator"
  value = [
    aws_globalaccelerator_endpoint_group.http.id,
    aws_globalaccelerator_endpoint_group.https.id,
    aws_globalaccelerator_endpoint_group.uplink.id,
    aws_globalaccelerator_endpoint_group.lxd.id
  ]
}