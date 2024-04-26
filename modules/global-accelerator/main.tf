locals {
  endpoints = var.balancer.enabled ? [var.balancer.id] : var.node_ids
}

resource "aws_globalaccelerator_accelerator" "this" {
  name            = var.identifier
  ip_address_type = "DUAL_STACK"
  enabled         = true

  tags = {
    Blueprint = var.blueprint
  }
}

resource "aws_globalaccelerator_listener" "http" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "http" {
  listener_arn                  = aws_globalaccelerator_listener.http.id
  endpoint_group_region         = var.region
  health_check_interval_seconds = 10
  health_check_port             = 80
  health_check_protocol         = "TCP"

  dynamic "endpoint_configuration" {
    for_each = local.endpoints

    content {
      endpoint_id                    = endpoint_configuration.value
      client_ip_preservation_enabled = true
    }
  }
}

resource "aws_globalaccelerator_listener" "https" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "https" {
  listener_arn                  = aws_globalaccelerator_listener.https.id
  endpoint_group_region         = var.region
  health_check_interval_seconds = 10
  health_check_port             = 443
  health_check_protocol         = "TCP"

  dynamic "endpoint_configuration" {
    for_each = local.endpoints

    content {
      endpoint_id                    = endpoint_configuration.value
      client_ip_preservation_enabled = true
    }
  }
}

resource "aws_globalaccelerator_listener" "uplink" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"

  port_range {
    from_port = 49152
    to_port   = 49152
  }
}

resource "aws_globalaccelerator_endpoint_group" "uplink" {
  listener_arn                  = aws_globalaccelerator_listener.uplink.id
  endpoint_group_region         = var.region
  health_check_interval_seconds = 10
  health_check_port             = 49152
  health_check_protocol         = "TCP"

  dynamic "endpoint_configuration" {
    for_each = local.endpoints

    content {
      endpoint_id                    = endpoint_configuration.value
      client_ip_preservation_enabled = true
    }
  }
}

resource "aws_globalaccelerator_listener" "lxd" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"

  port_range {
    from_port = 8443
    to_port   = 8443
  }
}

resource "aws_globalaccelerator_endpoint_group" "lxd" {
  listener_arn                  = aws_globalaccelerator_listener.lxd.id
  endpoint_group_region         = var.region
  health_check_interval_seconds = 10
  health_check_port             = 8443
  health_check_protocol         = "TCP"

  dynamic "endpoint_configuration" {
    for_each = local.endpoints

    content {
      endpoint_id                    = endpoint_configuration.value
      client_ip_preservation_enabled = true
    }
  }
}




