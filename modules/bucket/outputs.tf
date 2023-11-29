output "identifier" {
  value = "${var.identifier}-${random_string.this.result}-bucket"
}

output "access_key_id" {
  value = aws_iam_access_key.this.id
}

output "secret_access_key" {
  value = aws_iam_access_key.this.secret
  sensitive = true
}

output "region" {
  value = var.region
}

output "host" {
  value = "s3.${var.region}.amazonaws.com"
}