resource "random_string" "this" {
  length    = 6
  special   = false
  min_lower = 6
}

locals {
  sid = upper(random_string.this.result)
  bucket_name = "${var.bucket_name}-${random_string.this.result}"
  path = "/instellar/"
}

resource "aws_iam_policy" "this" {
  name        = "${var.bucket_name}-policy"
  path        = local.path
  description = "Allow"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowInstellar${local.sid}Access",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:ListBucket",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        "Resource" : [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*",
          "${aws_kms_key.this.arn}"
        ]
      }
    ],
  })
}

# tfsec:ignore:aws-iam-enforce-mfa
resource "aws_iam_group" "this" {
  name = "${var.bucket_name}-group"
  path = local.path
}

resource "aws_iam_user" "this" {
  name = "${var.bucket_name}-user"
  path = local.path

  tags = {
    Name = "${var.bucket_name}-user"
  }
}

resource "aws_iam_group_membership" "this" {
  name = "${var.bucket_name}-members"

  users = [
    aws_iam_user.this.name
  ]

  group = aws_iam_group.this.name
}

# tfsec:ignore:aws-s3-enable-versioning
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }
}

resource "aws_kms_key" "this" {
  description = "${var.bucket_name} Key"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.id
      sse_algorithm     = "aws:kms"
    }
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
  acl    = "private"
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}