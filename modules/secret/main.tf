resource "aws_secretsmanager_secret" "this" {
  name        = var.key
  name_prefix = var.blueprint
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
  name   = "${var.key}-secret-policy"
  policy = data.aws_iam_policy_document.this.json

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.nodes_iam_role.id
  policy_arn = aws_iam_policy.this.arn
}