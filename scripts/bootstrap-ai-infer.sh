#!/usr/bin/env bash
# Bootstrap the ai-infer VM: install NVIDIA driver + Ollama.
# Run inside the ai-infer VM as root.
set -euo pipefail

echo ">> Installing NVIDIA driver prerequisites"
apt-get update -y
apt-get install -y --no-install-recommends \
  curl ca-certificates linux-headers-$(uname -r) build-essential

echo ">> Installing NVIDIA driver (nvidia-driver-545 for GTX 1050 Ti)"
apt-get install -y --no-install-recommends nvidia-driver-545

echo ">> Verifying GPU"
nvidia-smi || { echo "GPU not visible — driver/passthrough issue"; exit 1; }

echo ">> Installing Ollama"
curl -fsSL https://ollama.com/install.sh | sh
systemctl enable ollama
systemctl restart ollama

echo ">> Pulling a small model (runs on GPU)"
ollama pull llama3.2:1b

echo ">> Allowing API access from the lab network"
# Ollama by default binds 127.0.0.1; expose on the LAN (internal net only).
sed -i 's|^#OLLAMA_HOST=.*|OLLAMA_HOST=0.0.0.0:11434|' /etc/systemd/system/ollama.service
systemctl daemon-reload && systemctl restart ollama

echo ">> Done. Test: curl localhost:11434/api/tags"
