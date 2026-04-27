resource "aws_instance" "control_plane" {
  count = var.control_plane_count

  ami           = var.ami_id
  instance_type = var.control_plane_instance_type
  subnet_id     = local.control_plane_subnets[count.index]

  vpc_security_group_ids      = local.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data != "" ? var.user_data : null

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot ? [1] : []

    content {
      market_type = "spot"

      spot_options {
        spot_instance_type = "one-time"
      }
    }
  }

  tags = merge(local.cp_tags, {
    Name = "${local.name_prefix}-cp-${count.index}"
  })
}


