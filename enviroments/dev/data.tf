# Data source to get the latest Talos AMI
data "aws_ami" "talos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["talos-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["540036508848"] # Sidero Labs account
}

# Data source to get a Linux AMI for the Tailscale router
data "aws_ami" "tailscale_router" {
  most_recent = true
  owners      = ["137112412989"] # Amazon Linux

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}