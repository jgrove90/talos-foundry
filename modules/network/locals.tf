locals {
  available_azs = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  az_count = var.high_availability ? length(local.available_azs) : 1

  selected_azs = slice(local.available_azs, 0, local.az_count)

  public_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(var.cidr_block, 8, i)
  ]

  private_subnet_cidrs = [
    for i in range(local.az_count) :
    cidrsubnet(var.cidr_block, 8, i + 10)
  ]
}