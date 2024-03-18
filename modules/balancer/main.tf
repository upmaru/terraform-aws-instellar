resource "aws_lb" "this" {
  name               = "${var.identifier}-balancer"
  load_balancer_type = "network"

  enable_deletion_protection = var.deletion_protection
}