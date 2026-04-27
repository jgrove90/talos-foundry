resource "aws_key_pair" "this" {
  count = var.manage_key_pair ? 1 : 0

  key_name   = var.key_name
  public_key = file(var.public_key_path)

  lifecycle {
    precondition {
      condition     = var.key_name != "" && var.public_key_path != ""
      error_message = "Set key_name and public_key_path when manage_key_pair is true."
    }
  }
}
