data "aws_iam_policy_document" "this" {
  count = var.manage_master_user_password ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_db_instance.this.master_user_secret[0].secret_arn
    ]
  }
}

resource "aws_iam_policy" "this" {
  count = var.manage_master_user_password ? 1 : 0

  name   = "${local.policy_name}SecretPolicy"
  policy = data.aws_iam_policy_document.this[0].json

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.manage_master_user_password ? 1 : 0

  role       = var.nodes_iam_role.id
  policy_arn = aws_iam_policy.this[0].arn
}