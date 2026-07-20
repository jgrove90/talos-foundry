# talos-foundry

Terraform for provisioning a Talos Kubernetes control plane on AWS, with private subnet access routed through a dedicated Tailscale subnet router.

## What This Repo Deploys

- An AWS VPC with public and private subnets.
- A NAT instance for outbound access from private subnets.
- Security groups and IAM instance profile for cluster nodes.
- Talos control plane EC2 instances.
- A dedicated Tailscale router EC2 instance so Terraform and operators can reach private Talos nodes.
- Talos bootstrap resources that generate `talosconfig` and `kubeconfig` into the selected environment's `credentials/` directory.

This repo does not provision worker nodes directly. The current intent is control plane provisioning first, with worker capacity managed separately.

## Repository Layout

```text
.
├── enviroments/
│   ├── dev/
│   └── prod/
├── modules/
│   ├── compute/
│   ├── network/
│   ├── security/
│   ├── talos-bootstrap/
│   └── vpn-tailscale/
└── providers.tf
```

## Bare Minimum Prerequisites

Before you run Terraform, have all of the following ready:

1. AWS credentials with permission to create VPC, EC2, route tables, security groups, IAM roles, and instance profiles.
2. Terraform `>= 1.0`.
3. A Tailscale tailnet and a reusable auth key for the subnet router.
4. An SSH public key if you want Terraform to manage the Tailscale router EC2 key pair.
5. Network access from your machine to Tailscale so you can later reach the private Talos control plane IPs.

Recommended local tools:

- `talosctl`
- `kubectl`

## How Access Works

The control plane instances are launched in private subnets. Terraform bootstraps Talos by connecting to those private node IPs, so the Tailscale router is part of the deployment path, not an optional extra.

High-level flow:

1. Terraform creates the VPC, routing, security groups, control plane nodes, and Tailscale router.
2. The Tailscale router joins your tailnet and advertises the VPC CIDR.
3. Your workstation reaches the private Talos IPs through Tailscale.
4. The `talos-bootstrap` module applies machine config, bootstraps the first control plane node, and writes local credentials.

## Tailscale Requirements

At minimum, set these environment values in the selected environment's `terraform.tfvars`:

- `tailscale_auth_key`
- `tailscale_advertise_routes`
- `tailscale_router_key_name`
- `manage_tailscale_router_key_pair`
- `tailscale_router_public_key_path`
- `tailscale_router_private_ip`
- `tailscale_router_hostname`

Important operational notes:

- The router advertises the VPC CIDR, for example `10.20.0.0/16` in prod.
- Depending on your Tailscale policy, you may need to approve the new device, advertised route, or tag in the Tailscale admin console before private subnet access works.
- The router instance does not receive a public IP. Access is expected to come through Tailscale.
- Do not commit Tailscale auth keys into `terraform.tfvars`. Pass them through a secure secret source or `TF_VAR_tailscale_auth_key`.

Example:

```bash
export TF_VAR_tailscale_auth_key="tskey-auth-..."
```

## Environment Quick Start

Pick one environment and deploy from that directory.

### Development

Development is the cheaper test path. It still uses private subnets plus the Tailscale router for Talos access.

1. Open [enviroments/dev/terraform.tfvars](/home/jgrove/git/talos-foundry/enviroments/dev/terraform.tfvars) and set:
	- `vpc_cidr_block`
	- `common_tags`
	- `tailscale_router_key_name`
	- `tailscale_router_public_key_path`
	- `tailscale_router_private_ip`
	- `tailscale_advertise_routes`
	- `tailscale_router_hostname`
2. Provide the Tailscale auth key securely, preferably via `TF_VAR_tailscale_auth_key`.
3. Deploy:

```bash
cd enviroments/dev
terraform init
terraform plan
terraform apply
```

4. Wait until the Tailscale router appears in your tailnet and the advertised route is active.
5. Confirm the credentials were written to [enviroments/dev/credentials](/home/jgrove/git/talos-foundry/enviroments/dev/credentials).

### Production

Production adds multi-AZ control plane nodes, strict egress, and private-only node access.

1. Open [enviroments/prod/terraform.tfvars](/home/jgrove/git/talos-foundry/enviroments/prod/terraform.tfvars) and set:
	- `vpc_cidr_block`
	- `control_plane_private_ips`
	- `talos_api_allowed_cidrs`
	- `common_tags`
	- `tailscale_router_key_name`
	- `tailscale_router_public_key_path`
	- `tailscale_router_private_ip`
	- `tailscale_advertise_routes`
	- `tailscale_router_hostname`
2. Provide the Tailscale auth key securely, preferably via `TF_VAR_tailscale_auth_key`.
3. Deploy:

```bash
cd enviroments/prod
terraform init
terraform plan
terraform apply
```

4. Approve the Tailscale router or route advertisement if your tailnet requires it.
5. Confirm the credentials were written to [enviroments/prod/credentials](/home/jgrove/git/talos-foundry/enviroments/prod/credentials).

## Minimal End-to-End Deployment Steps

If you only need the shortest working path, use this checklist:

1. Export AWS credentials in your shell.
2. Export `TF_VAR_tailscale_auth_key`.
3. Set the chosen environment's `terraform.tfvars` values for CIDR, tags, router key pair, and router private IP.
4. Run `terraform init`, `terraform plan`, and `terraform apply` from `enviroments/dev` or `enviroments/prod`.
5. In Tailscale, confirm the subnet router is online and its advertised route is approved.
6. Use the generated `talosconfig` and `kubeconfig` from that environment's `credentials/` directory.

## Using the Generated Credentials

After a successful apply, Terraform writes:

- `credentials/talosconfig`
- `credentials/kubeconfig`

Example:

```bash
cd enviroments/prod
talosctl --talosconfig credentials/talosconfig version
KUBECONFIG=credentials/kubeconfig kubectl get nodes
```

## What to Configure in Each Environment

The most important variables live in each environment directory.

Common values to review:

- `cluster_name`
- `environment`
- `vpc_cidr_block`
- `common_tags`
- `control_plane_private_ips`
- `talos_api_allowed_cidrs`
- `enable_strict_egress`
- `tailscale_auth_key`
- `tailscale_advertise_routes`
- `tailscale_router_key_name`
- `manage_tailscale_router_key_pair`
- `tailscale_router_public_key_path`
- `tailscale_router_private_ip`
- `tailscale_router_hostname`

## Current Operational Notes

- The AWS provider region is fixed in [providers.tf](/home/jgrove/git/talos-foundry/providers.tf).
- Production currently uses a local Terraform backend in [enviroments/prod/backend.tf](/home/jgrove/git/talos-foundry/enviroments/prod/backend.tf), so set up remote state before treating it as team-safe.
- The Talos bootstrap phase requires private connectivity to the control plane nodes. If the Tailscale route is not active, bootstrap will fail.

## Troubleshooting

### Terraform apply cannot reach Talos nodes

Check these first:

1. The Tailscale router instance is online in your tailnet.
2. The advertised route is approved.
3. Your workstation is connected to Tailscale.
4. The selected environment's VPC CIDR matches the route being advertised.

### Router key pair creation fails

If `manage_tailscale_router_key_pair = true`, both of these must be set:

- `tailscale_router_key_name`
- `tailscale_router_public_key_path`

### No credentials were written

Check whether the `talos-bootstrap` step failed after infrastructure creation. The bootstrap module writes credentials only after it can talk to the control plane.
