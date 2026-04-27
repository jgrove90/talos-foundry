variable "cluster_name" {
  description = "Name of the Kubernetes cluster. Used as a prefix for naming AWS resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name used for tagging."
  type        = string
  default     = "dev"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances. Should span multiple AZs for HA."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet must be provided."
  }
}

variable "control_plane_count" {
  description = "Number of control plane nodes. Use 1 for dev, 3 for HA production clusters."
  type        = number
  default     = 1
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for control plane nodes."
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI ID used for control plane EC2 nodes (Talos Linux image)."
  type        = string
}

variable "security_group_id" {
  description = "Primary security group ID applied to all compute instances."
  type        = string
}

variable "security_group_ids" {
  description = "Optional additional security groups to attach to compute instances."
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name attached to EC2 instances."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name for instance access."
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IP addresses with instances."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional user data to configure EC2 instances."
  type        = string
  default     = ""
}

variable "use_spot" {
  description = "Whether to launch instances as spot instances."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to compute resources."
  type        = map(string)
  default     = {}
}