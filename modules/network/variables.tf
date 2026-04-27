variable "name_prefix" {
  description = "Prefix to use for AWS resource names."
  type        = string
  default     = "talos-foundry"
}

variable "common_tags" {
  description = "Common tags to apply to all network resources."
  type        = map(string)
  default     = {}
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Optional list of AZs to use. If empty, the module selects available AZs in the region."
  type        = list(string)
  default     = []
}

variable "high_availability" {
  description = "Whether to create subnets across all available AZs. When false, a single AZ is used."
  type        = bool
  default     = false
}

variable "create_internet_gateway" {
  description = "Whether to create an internet gateway and public route for the VPC."
  type        = bool
  default     = true
}