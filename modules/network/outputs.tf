output "public_subnet_ids" {
  value = aws_subnet.this[*].id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_ip_range" {
  value = var.vpc_ip_range
}

output "dependencies" {
  value = [
    aws_internet_gateway.this.id,
    aws_route_table.public.id,
    aws_route_table_association.public[*].id
  ]
}