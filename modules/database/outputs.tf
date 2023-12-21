output "identifier" {
  description = "The database identifier"
  value       = aws_db_instance.this.identifier
}

output "address" {
  description = "The database address"
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "The database master username"
  value       = aws_db_instance.this.username
}

output "password" {
  description = "The database master password"
  value       = aws_db_instance.this.password
}

output "port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "certificate_url" {
  description = "The certificate url for using with the database."
  value       = "https://truststore.pki.rds.amazonaws.com/${var.region}/${var.region}-bundle.pem"
}

output "engine_version" {
  description = "The database engine version"
  value       = aws_db_instance.this.engine_version_actual
}
