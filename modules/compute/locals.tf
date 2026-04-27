locals {
  name_prefix = var.cluster_name

  common_tags = merge(var.tags, {
    Project     = "talos-foundry"
    Environment = var.environment
    ManagedBy   = "terraform"
    Cluster     = var.cluster_name
  })

  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [var.security_group_id]

  control_plane_tags = {
    Role = "control-plane"
  }

  cp_tags = merge(local.common_tags, local.control_plane_tags)

  control_plane_subnets = [
    for i in range(var.control_plane_count) :
    var.subnet_ids[i % length(var.subnet_ids)]
  ]
}
