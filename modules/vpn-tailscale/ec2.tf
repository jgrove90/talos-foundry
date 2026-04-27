resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  private_ip    = var.private_ip != "" ? var.private_ip : null

  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null
  key_name                    = var.manage_key_pair ? aws_key_pair.this[0].key_name : (var.key_name != "" ? var.key_name : null)
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data != "" ? var.user_data : null
  source_dest_check           = false

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(local.common_tags, var.router_tags, {
    Name = "${local.name_prefix}-tailscale-router"
    Role = "tailscale-router"
  })
}
