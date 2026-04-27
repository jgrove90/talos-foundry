output "id" {
  description = "ID of the Tailscale subnet router instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the Tailscale subnet router instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the Tailscale subnet router instance, if assigned."
  value       = aws_instance.this.public_ip
}
