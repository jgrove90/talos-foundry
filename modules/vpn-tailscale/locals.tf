locals {
  name_prefix = var.cluster_name

  common_tags = merge(var.tags, {
    Project     = "talos-foundry"
    Environment = var.environment
    ManagedBy   = "terraform"
    Cluster     = var.cluster_name
  })
}
