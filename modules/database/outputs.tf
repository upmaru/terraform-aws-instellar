output "address" {
  description = "The database address"
  value       = aws_db_instance.database.address
}

output "endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.database.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.database.db_name
}

output "username" {
  description = "The database master username"
  value       = aws_db_instance.database.username
}

output "password" {
  description = "The database master password"
  value       = aws_db_instance.database.password
}

output "engine_version" {
  description = "The database engine version"
  value       = aws_db_instance.database.engine_version_actual
}
