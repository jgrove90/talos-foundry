output "control_plane_private_ips" {
  description = "Private IP addresses for control plane instances."
  value       = aws_instance.control_plane[*].private_ip
}

output "control_plane_ids" {
  description = "IDs of control plane EC2 instances."
  value       = aws_instance.control_plane[*].id
}

output "control_plane_public_ips" {
  description = "Public IP addresses for control plane instances, if assigned."
  value       = aws_instance.control_plane[*].public_ip
}

output "iam_instance_profile_name" {
  description = "The IAM instance profile name attached to compute instances."
  value       = var.iam_instance_profile_name
}