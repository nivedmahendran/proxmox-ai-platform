# Runbooks — operational procedures. Interviewers love these.

## RB-001: Rebuild any guest from Terraform
```bash
./scripts/provision.sh
```
Terraform reconciles to the desired state. Q: any guest removed manually, run
`terraform apply` again to restore it.

## RB-002: Rebuild the ai-infer GPU VM
```bash
# 1. Remove the VM and re-apply (idempotent)
terraform destroy -target=proxmox_virtual_environment_vm.ai_infer
./scripts/provision.sh
# 2. Bootstrap Ollama + NVIDIA driver inside the VM
ssh ubuntu@10.10.10.120 'sudo bash -s' < scripts/bootstrap-ai-infer.sh
```

## RB-003: Verify the whole stack
```bash
curl -s http://10.10.10.122/api/health   # edge -> platform -> ai-infer
curl -s http://10.10.10.122/api/chat -H 'content-type: application/json' \
  -d '{"message":"hello"}'
# Grafana: http://10.10.10.123:3000
```

## RB-004: GPU troubleshooting
```bash
# on host:
lspci -nnk | grep -A3 -i nvidia    # kernel driver should be vfio-pci
# inside ai-infer VM:
nvidia-smi                          # should show the GPU; else driver/passthrough issue
journalctl -u ollama -f             # Ollama logs
```

## RB-005: Restore from backup
See [backups.md](backups.md).

## RB-006: Redeploy the demo-api
Push to `main` → GitHub Actions deploy workflow (self-hosted runner) → SSH to
platform → `docker compose up -d --build`.

## RB-007: Rotate the GitHub token for the runner
```bash
# On the runner container (10.10.10.124):
cd /opt/actions-runner && ./config.sh --remove --token <NEW_TOKEN>
../scripts/install-runner.sh nivedmahendran/proxmox-ai-platform <NEW_TOKEN>
```
