#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/tailscale-router-bootstrap.log | logger -t tailscale-router-bootstrap -s 2>/dev/console) 2>&1

# Simple installer for Tailscale subnet router.
# Expects auth key and advertised routes to be provided via template substitution.

if ! command -v curl >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    # Amazon Linux 2023 ships curl-minimal by default; prefer that package to avoid conflicts.
    dnf install -y curl-minimal || dnf install -y curl
  elif command -v yum >/dev/null 2>&1; then
    yum install -y curl
  elif command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y curl
  else
    echo "Unsupported package manager" >&2
    exit 1
  fi
fi

curl -fsSL https://tailscale.com/install.sh | sh

mkdir -p /etc/sysctl.d
cat <<'EOF' >/etc/sysctl.d/99-tailscale-router.conf
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
sysctl --system

TAILSCALE_AUTH_KEY="${auth_key}"
TAILSCALE_ADVERTISE_ROUTES="${advertise_routes}"
TAILSCALE_HOSTNAME="${hostname}"

if [ -z "$${TAILSCALE_AUTH_KEY}" ]; then
  echo "Error: TAILSCALE_AUTH_KEY must be provided" >&2
  exit 1
fi

systemctl enable --now tailscaled

for attempt in 1 2 3 4 5; do
  if /usr/bin/tailscale up \
    --authkey "$${TAILSCALE_AUTH_KEY}" \
    --advertise-routes="$${TAILSCALE_ADVERTISE_ROUTES}" \
    --accept-routes=false \
    --hostname="$${TAILSCALE_HOSTNAME}" \
    --advertise-exit-node=false; then
    exit 0
  fi

  echo "tailscale up failed on attempt $${attempt}; retrying" >&2
  sleep 5
done

echo "tailscale up failed after multiple attempts" >&2
exit 1
