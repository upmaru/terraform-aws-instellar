resource "random_string" "this" {
  length    = 6
  special   = false
  min_lower = 6
}

locals {
  sid = upper(random_string.this.result)
  path = "/instellar/"
}

resource "aws_iam_policy" "this" {
  name = "${var.identifier}-${random_string.this.result}-policy"
  path = local.path
  description = "For generatinga application buckets."
  policy = jsondecide({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid" = "AllowOpsmaru${local.sid}BucketGeneration",
        "Effect" = "Allow",
        "Action" = [
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketAcl",
          "s3:CreateBucket",
          "s3:PutBucketCORS",
          "iam:CreatePolicy",
          "iam:AttachUserPolicy",
          "iam:CreateUser",
          "iam:TagUser",
          "iam:CreateAccessKey"
        ]
      }
    ]
  })
}

resource "aws_iam_user" "this" {
  name = "${var.identifier}-${random_string.this.result}-user"
  path = local.path
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "this" {
  user = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this.arn
}