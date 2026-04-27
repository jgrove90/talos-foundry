resource "aws_security_group_rule" "all_egress_cp" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = var.enable_strict_egress ? [] : ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_egress_worker" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = aws_security_group.worker.id
  cidr_blocks       = var.enable_strict_egress ? [] : ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_egress_tailscale_router" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = aws_security_group.tailscale_router.id
  cidr_blocks       = var.enable_strict_egress ? [] : ["0.0.0.0/0"]
}

# Strict egress rules when enabled
resource "aws_security_group_rule" "https_egress_cp" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_egress_cp" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_egress_worker" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_egress_worker" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_egress_tailscale_router" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.tailscale_router.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_egress_tailscale_router" {
  count = var.enable_strict_egress ? 1 : 0

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = aws_security_group.tailscale_router.id
  cidr_blocks       = ["0.0.0.0/0"]
}