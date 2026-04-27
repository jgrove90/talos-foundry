# Dev Environment Variables
# These override global defaults for development-specific settings

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "talos-dev"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "talos_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access Talos API (open for dev)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_strict_egress" {
  description = "Whether to restrict egress traffic"
  type        = bool
  default     = false
}

variable "common_tags" {
  type = map(string)
}

variable "vpc_cidr_block" {
  type = string
}


variable "additional_iam_policies" {
  description = "Additional IAM policies to attach to EC2 role"
  type        = list(string)
  default     = []
}

variable "compute_key_name" {
  description = "Optional EC2 key pair name attached to compute module instances."
  type        = string
  default     = ""
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used by the subnet router bootstrap script"
  type        = string
  sensitive   = true
}

variable "tailscale_advertise_routes" {
  description = "Comma-separated CIDRs to advertise through the Tailscale router"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_ssh_from_tailscale" {
  description = "Allow SSH to the Tailscale router from tailscale_allowed_cidrs."
  type        = bool
  default     = true
}

variable "tailscale_router_key_name" {
  description = "EC2 key pair name used for SSH access to the Tailscale router."
  type        = string
  default     = ""
}

variable "manage_tailscale_router_key_pair" {
  description = "Whether Terraform should manage/import the Tailscale router EC2 key pair in AWS."
  type        = bool
  default     = false
}

variable "tailscale_router_public_key_path" {
  description = "Path to the local public key file used when managing/importing the Tailscale router EC2 key pair."
  type        = string
  default     = ""
}

variable "tailscale_router_private_ip" {
  description = "Optional static private IPv4 for the Tailscale router in the selected private subnet."
  type        = string
  default     = ""
}

variable "tailscale_router_hostname" {
  description = "Hostname used by tailscale up for the subnet router node."
  type        = string
  default     = "talos-dev-tailscale-router"
}