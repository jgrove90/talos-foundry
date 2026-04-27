resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_name}-control-plane"
  description = "Control plane security group"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-control-plane"
  })
}

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-worker"
  description = "Worker security group"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-worker"
  })
}

resource "aws_security_group" "tailscale_router" {
  name        = "${var.cluster_name}-tailscale-router"
  description = "Security group for the Tailscale subnet router"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-tailscale-router"
  })
}
