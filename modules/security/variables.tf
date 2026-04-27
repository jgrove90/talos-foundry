variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "talos_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access Talos API"
  type        = list(string)
  default     = []
}

variable "tailscale_allowed_cidrs" {
  description = "CIDR blocks allowed for Tailscale subnet router traffic."
  type        = list(string)
  default     = ["100.64.0.0/10"]
}

variable "enable_ssh_from_tailscale" {
  description = "Whether to allow SSH (tcp/22) from tailscale_allowed_cidrs to the Tailscale router security group."
  type        = bool
  default     = false
}

variable "enable_strict_egress" {
  description = "Whether to restrict egress traffic (recommended for production)"
  type        = bool
  default     = false
}

variable "additional_iam_policies" {
  description = "Additional IAM policies to attach to EC2 role"
  type        = list(string)
  default     = []
}