# Network Module

This module creates a VPC with public and private subnets, plus optional internet gateway support.

## Features

- `high_availability` toggles between a single-AZ deployment and multi-AZ deployments
- `availability_zones` may be provided explicitly, otherwise the module selects available AZs automatically
- Public and private subnet creation with consistent CIDR assignment
- Public route table and optional Internet Gateway
- Tagged resources using `common_tags` and `name_prefix`

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Prefix for all resource names | `string` | `talos-foundry` |
| `common_tags` | Common tags applied to all resources | `map(string)` | `{}` |
| `cidr_block` | VPC CIDR block | `string` | `10.0.0.0/16` |
| `availability_zones` | Optional AZ list; module discovers AZs if empty | `list(string)` | `[]` |
| `high_availability` | Create resources across all selected AZs when true | `bool` | `false` |
| `create_internet_gateway` | Create an Internet Gateway and public route | `bool` | `true` |

## Outputs

- `vpc_id`
- `public_subnets`
- `private_subnets`
- `public_route_table_id`
- `private_route_table_ids`
- `availability_zones`
