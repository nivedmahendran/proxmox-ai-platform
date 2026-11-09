#!/usr/bin/env bash
# Install and register a self-hosted GitHub Actions runner on the lab network.
# Usage: ./install-runner.sh <RUNNER_REPO> <RUNNER_TOKEN>
set -euo pipefail

REPO="${1:?usage: install-runner.sh <repo> <token>}"
TOKEN="${2:?usage: install-runner.sh <repo> <token>}"

RUNNER_VERSION="2.328.0"
WORKDIR="/opt/actions-runner"

echo ">> Creating runner user"
id runner 2>/dev/null || useradd -m -s /bin/bash runner

echo ">> Downloading runner"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
curl -fsSL -o runner.tar.gz \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
tar xzf runner.tar.gz
rm runner.tar.gz

echo ">> Configuring runner (system service)"
./config.sh --url "https://github.com/${REPO}" --token "$TOKEN" \
  --name "proxmox-lab-runner" --labels self-hosted,linux,x64,proxmox \
  --unattended --replace

./svc.sh install runner
./svc.sh start

echo ">> Runner installed and running."
