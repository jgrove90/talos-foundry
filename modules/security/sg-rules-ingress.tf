resource "aws_security_group_rule" "cp_to_cp" {
  description              = "Allow control plane nodes to talk to each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "worker_to_cp_api" {
  description              = "Workers to Kubernetes API"
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "cp_to_worker_kubelet" {
  description              = "Control plane to worker kubelet"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "node_to_node" {
  description              = "Worker node to worker node"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "talos_api" {
  description       = "Allow Talos API"
  type              = "ingress"
  from_port         = 50000
  to_port           = 50001
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = var.talos_api_allowed_cidrs
}

# Additional Kubernetes control plane ports
resource "aws_security_group_rule" "etcd_client" {
  description              = "etcd client requests"
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "kube_scheduler" {
  description              = "kube-scheduler health checks"
  type                     = "ingress"
  from_port                = 10251
  to_port                  = 10251
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "kube_controller_manager" {
  description              = "kube-controller-manager health checks"
  type                     = "ingress"
  from_port                = 10252
  to_port                  = 10252
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "talos_api_admin" {
  description       = "Talos API for Admin Management"
  type              = "ingress"
  from_port         = 50000
  to_port           = 50000
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = var.tailscale_allowed_cidrs
}

resource "aws_security_group_rule" "tailscale_to_control_plane" {
  description       = "Allow Tailscale subnet router traffic to control plane nodes"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.control_plane.id
  cidr_blocks       = var.tailscale_allowed_cidrs
}

resource "aws_security_group_rule" "tailscale_to_worker" {
  description       = "Allow Tailscale subnet router traffic to worker nodes"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker.id
  cidr_blocks       = var.tailscale_allowed_cidrs
}

resource "aws_security_group_rule" "ssh_to_tailscale_router" {
  count = var.enable_ssh_from_tailscale ? 1 : 0

  description       = "Allow SSH from Tailscale CIDRs to the Tailscale router"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.tailscale_router.id
  cidr_blocks       = var.tailscale_allowed_cidrs
}

resource "aws_security_group_rule" "talos_trust_internal" {
  description              = "Allow Workers to join via Trustd"
  type                     = "ingress"
  from_port                = 50001
  to_port                  = 50001
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "talos_api_internal" {
  description              = "Allow nodes to talk to each others APIs"
  type                     = "ingress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.control_plane.id
}