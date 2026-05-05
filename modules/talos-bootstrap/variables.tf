variable "cluster_name" {
  description = "Talos/Kubernetes cluster name."
  type        = string
}

variable "control_plane_nodes" {
  description = "List of control plane node IPs reachable by Terraform for Talos API operations."
  type        = list(string)

  validation {
    condition     = length(var.control_plane_nodes) > 0
    error_message = "At least one control plane node IP must be provided."
  }
}

variable "cluster_endpoint" {
  description = "Optional explicit Kubernetes API endpoint (for example, load balancer VIP)."
  type        = string
  default     = ""
}

variable "talos_version" {
  description = "Talos version contract used to generate machine secrets and config."
  type        = string
  default     = "v1.12"
}

variable "apply_mode" {
  description = "Apply mode for talos_machine_configuration_apply (for example, auto, staged)."
  type        = string
  default     = "auto"
}

variable "controlplane_config_patches" {
  description = "Optional list of YAML patches applied to generated control plane machine config."
  type        = list(string)
  default     = []
}

variable "config_output_dir" {
  description = "Directory where talosconfig and kubeconfig are written after bootstrap."
  type        = string
  default     = ""
}