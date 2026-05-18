locals {
  high_availability           = false
  control_plane_count         = 1
  control_plane_instance_type = "t3.medium"
  use_spot                    = true
  enable_tailscale_router     = true
  tailscale_subnet_index      = 0

  common_tags = var.common_tags
}
