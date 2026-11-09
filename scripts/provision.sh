#!/usr/bin/env bash
# Provision all Proxmox guests from Terraform.
set -euo pipefail

cd "$(dirname "$0")/../terraform/proxmox"

# Read credentials from the MCP env file (or set your own). Do NOT commit.
if [ -f /home/nived/.venvs/mcp-proxmox/proxmox.env ]; then
  set -a
  # shellcheck disable=SC1091
  source /home/nived/.venvs/mcp-proxmox/proxmox.env
  set +a
  export TF_VAR_proxmox_token="$PROXMOX_TOKEN_SECRET"
fi

terraform init -upgrade
terraform plan -out=tfplan
terraform apply tfplan
