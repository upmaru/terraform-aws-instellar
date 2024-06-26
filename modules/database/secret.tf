locals {
  nodes_iam_roles = {
    for role in var.nodes_iam_roles : role.name => role
  }
}

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
  for_each = var.manage_master_user_password ? local.nodes_iam_roles : {}

  role       = each.value.id
  policy_arn = aws_iam_policy.this[0].arn
}