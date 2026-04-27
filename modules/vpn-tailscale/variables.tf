variable "cluster_name" {
  description = "Name of the Kubernetes cluster. Used as a prefix for naming AWS resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name used for tagging."
  type        = string
  default     = "dev"
}

variable "subnet_id" {
  description = "Subnet ID for the Tailscale subnet router instance."
  type        = string
}

variable "private_ip" {
  description = "Optional static private IPv4 address for the Tailscale subnet router instance."
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID used for the Tailscale subnet router instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Tailscale subnet router."
  type        = string
  default     = "t3.micro"
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the Tailscale subnet router instance."
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name for the Tailscale subnet router instance."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Optional EC2 key pair name for the Tailscale subnet router instance."
  type        = string
  default     = ""
}

variable "manage_key_pair" {
  description = "Whether this module should manage/import the EC2 key pair in AWS."
  type        = bool
  default     = false
}

variable "public_key_path" {
  description = "Path to the local public key file used when manage_key_pair is true."
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IP to the Tailscale subnet router instance."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional user data to bootstrap the Tailscale subnet router."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to module resources."
  type        = map(string)
  default     = {}
}

variable "router_tags" {
  description = "Additional tags to apply to the Tailscale router instance."
  type        = map(string)
  default     = {}
}
