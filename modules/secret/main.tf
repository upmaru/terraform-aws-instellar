resource "aws_secretsmanager_secret" "this" {
  name = var.identifier
  name_prefix = var.blueprint
  description = var.description

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = var.secret_value
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
  name = "${var.identifier}-secret-policy"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.nodes_iam_role.id
  policy_arn = aws_iam_policy.this.arn
}