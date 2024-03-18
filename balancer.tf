resource "aws_lb" "this" {
  count = var.load_balancer ? 1 : 0

  name = "${var.identifier}-balancer"
  load_balancer_type = "network"

  enable_deletion_protection = true
}