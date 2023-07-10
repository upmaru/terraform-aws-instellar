resource "random_string" "this" {
  length = 6
  special = false
  min_lower = 6
} 

locals {
  bucket_name = "${var.bucket_name}-${random_string.this.result}"
}

resource "aws_iam_policy" "this" {
  name = "${var.bucket_name}-policy"
  path = "/"
  description = "Allow"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "AllowInstellar${var.bucket_name}Access",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "this" {
  name = "${var.bucket_name}-user"

  tags = {
    Name = "${var.bucket_name}-user"
  }
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl = "private"
}

resource "aws_iam_user_policy_attachment" "this" {
  user = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}