locals {
  policy_name = replace(title(var.key), "/", "")
  nodes_iam_roles = {
    for role in var.nodes_iam_roles : role.name => role
  }
}

resource "aws_secretsmanager_secret" "this" {
  name        = var.key
  description = var.description

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.value
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.this.arn
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = "${local.policy_name}SecretPolicy"
  policy = data.aws_iam_policy_document.this.json

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.nodes_iam_roles

  role       = each.value.id
  policy_arn = aws_iam_policy.this.arn
}