output "name" {
  value = local.bucket_name
}

output "access_key_id" {
  value = aws_iam_access_key.this.id
}

output "secret_access_key" {
  value = aws_iam_access_key.this.secret
  sensitive = true
}

output "host" {
  value = "s3-${aws_s3_bucket.this.region}.amazonaws.com"
}