# Production Environment Configuration
# This environment uses multi-AZ HA deployment with NAT gateway


# Network Module - Multi-AZ HA for prod
module "network" {
  source = "../../modules/network"

  name_prefix             = var.cluster_name
  common_tags             = local.common_tags
  cidr_block              = var.vpc_cidr_block
  high_availability       = local.high_availability
  create_internet_gateway = true
}

# NAT Gateway for private subnet internet access
module "fck-nat" {
  source = "git::https://github.com/RaJiska/terraform-aws-fck-nat.git"

  name   = "${var.cluster_name}-nat"
  vpc_id = module.network.vpc_id

  subnet_id = module.network.public_subnets[0]

  update_route_tables = true

  route_tables_ids = {
    for idx, rt_id in module.network.private_route_table_ids :
    "private-${idx}" => rt_id
  }
}

# Security Module
module "security" {
  source = "../../modules/security"

  cluster_name              = var.cluster_name
  vpc_id                    = module.network.vpc_id
  vpc_cidr_block            = var.vpc_cidr_block
  common_tags               = local.common_tags
  talos_api_allowed_cidrs   = var.talos_api_allowed_cidrs
  enable_ssh_from_tailscale = var.enable_ssh_from_tailscale
  enable_strict_egress      = var.enable_strict_egress
  additional_iam_policies   = var.additional_iam_policies
}

# Compute Module - Control plane only (workers managed by Karpenter)
module "talos-cp" {
  source = "../../modules/compute"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  subnet_ids                  = module.network.private_subnets
  control_plane_private_ips   = var.control_plane_private_ips
  control_plane_count         = local.control_plane_count
  control_plane_instance_type = local.control_plane_instance_type
  ami_id                      = data.aws_ami.talos.id
  security_group_id           = module.security.control_plane_sg_id
  iam_instance_profile_name   = module.security.iam_instance_profile_name
  key_name                    = var.compute_key_name
  associate_public_ip_address = false
  use_spot                    = local.use_spot
  tags                        = local.common_tags
}

module "talos-bootstrap" {
  source = "../../modules/talos-bootstrap"

  cluster_name        = var.cluster_name
  control_plane_nodes = module.talos-cp.control_plane_private_ips
  talos_version       = var.talos_version
  config_output_dir   = "${path.module}/credentials"

  depends_on = [module.talos-cp, module.tailscale-vpn-router]
}

module "tailscale-vpn-router" {
  count  = local.enable_tailscale_router ? 1 : 0
  source = "../../modules/vpn-tailscale"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  subnet_id                   = module.network.private_subnets[local.tailscale_subnet_index]
  private_ip                  = var.tailscale_router_private_ip
  ami_id                      = data.aws_ami.tailscale_router.id
  instance_type               = "t3.micro"
  security_group_ids          = [module.security.tailscale_router_sg_id]
  iam_instance_profile_name   = module.security.iam_instance_profile_name
  key_name                    = var.tailscale_router_key_name
  manage_key_pair             = var.manage_tailscale_router_key_pair
  public_key_path             = var.tailscale_router_public_key_path
  associate_public_ip_address = false
  tags                        = local.common_tags
  user_data = templatefile("${path.module}/../../modules/vpn-tailscale/tailscale-router-userdata.sh.tpl", {
    auth_key         = var.tailscale_auth_key
    advertise_routes = var.tailscale_advertise_routes
    hostname         = var.tailscale_router_hostname
  })
}