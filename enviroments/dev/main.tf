# Dev Environment Configuration
# This environment uses single-AZ deployment for cost efficiency

# Network Module - Single AZ for dev
module "network" {
  source = "../../modules/network"

  name_prefix             = var.cluster_name
  common_tags             = var.common_tags
  cidr_block              = var.vpc_cidr_block
  high_availability       = false
  create_internet_gateway = true
}

# Security Module
module "security" {
  source = "../../modules/security"

  cluster_name              = var.cluster_name
  vpc_id                    = module.network.vpc_id
  common_tags               = var.common_tags
  talos_api_allowed_cidrs   = var.talos_api_allowed_cidrs
  enable_ssh_from_tailscale = var.enable_ssh_from_tailscale
  enable_strict_egress      = var.enable_strict_egress
  additional_iam_policies   = var.additional_iam_policies
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


# Compute Module - Control plane only (workers managed by Karpenter)
module "talos-cp" {
  source = "../../modules/compute"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  subnet_ids                  = module.network.private_subnets
  control_plane_count         = 1
  control_plane_instance_type = "t3.medium"
  ami_id                      = data.aws_ami.talos.id
  security_group_id           = module.security.control_plane_sg_id
  iam_instance_profile_name   = module.security.iam_instance_profile_name
  key_name                    = var.compute_key_name
  associate_public_ip_address = false
  use_spot                    = true
  tags                        = var.common_tags
}

module "tailscale-vpn-router" {
  source = "../../modules/vpn-tailscale"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  subnet_id                   = module.network.private_subnets[0]
  private_ip                  = var.tailscale_router_private_ip
  ami_id                      = data.aws_ami.tailscale_router.id
  instance_type               = "t3.micro"
  security_group_ids          = [module.security.tailscale_router_sg_id]
  iam_instance_profile_name   = module.security.iam_instance_profile_name
  key_name                    = var.tailscale_router_key_name
  manage_key_pair             = var.manage_tailscale_router_key_pair
  public_key_path             = var.tailscale_router_public_key_path
  associate_public_ip_address = false
  tags                        = var.common_tags
  user_data = templatefile("${path.module}/../../modules/vpn-tailscale/tailscale-router-userdata.sh.tpl", {
    auth_key         = var.tailscale_auth_key
    advertise_routes = var.tailscale_advertise_routes
    hostname         = var.tailscale_router_hostname
  })

}