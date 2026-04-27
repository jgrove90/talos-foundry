output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  description = "IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs of private subnets."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "Route table ID for public subnets."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Route table IDs for private subnets."
  value       = aws_route_table.private[*].id
}

output "availability_zones" {
  description = "Availability zones used by the module."
  value       = local.selected_azs
}