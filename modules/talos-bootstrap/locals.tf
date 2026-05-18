locals {
  control_plane_nodes = sort(var.control_plane_nodes)
  bootstrap_node      = local.control_plane_nodes[0]
  follower_nodes      = slice(local.control_plane_nodes, 1, length(local.control_plane_nodes))
  cluster_endpoint    = var.cluster_endpoint != "" ? var.cluster_endpoint : "https://${local.bootstrap_node}:6443"
}
