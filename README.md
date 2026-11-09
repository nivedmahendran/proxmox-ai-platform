# Proxmox AI Platform

> **A self-hosted GitOps platform on Proxmox that trains nothing, serves something,**
> **and is fully reproducible from a single repository.**

A production-style *"control plane as code"* homelab that runs a real AI inference
service on an NVIDIA GPU behind a versioned API — all provisioned from Terraform,
deployed by GitHub Actions (self-hosted runner on the lab network), reconciled by
GitOps, and watched by Prometheus/Grafana.

Built to demonstrate the platform-engineering skills that are hard to fake:
**infrastructure as code, GitOps, progressive delivery, observability, and a
working CI/CD loop that actually touches the environment.**

---

## Why this project exists (the pitch)

Most homelabs are a pile of YAML. This one is a **disciplined platform**:

| Skill | Shown by |
|---|---|
| IaC | Terraform provisions every Proxmox guest (VMs/CTs), including the GPU box |
| GitOps | ArgoCD reconciles the cluster from this repo |
| CI/CD | GitHub Actions builds the API image, pushes it, and deploys **via a self-hosted runner on the lab network** |
| GPU/AI | Ollama + GTX 1050 Ti passthrough behind a FastAPI gateway |
| Observability | Prometheus + Grafana dashboards, alerting |
| Reliability | Backups (vzdump + etcd snapshot), runbooks, decision log |

---

## Architecture

```
┌────────────────────────────── GitHub ─────────────────────────────┐
│  proxmox-ai-platform (this repo)                                  │
│   ├─ .github/workflows/ci.yml        build+test API image          │
│   ├─ .github/workflows/deploy.yml    SSH: runner on lab net        │
│   └─ terraform/                      provisions the guests          │
└──────────────┬───────────────────────────────────┬─────────────────┘
               │ push                              │ GH Actions (self-hosted runner)
               ▼                                  ▼
┌────────────────────────── Proxmox (pve) ──────────────────────────┐
│  vmbr0 / 10.10.10.0/22                                            │
│                                                                   │
│  ┌─────────────────────┐   ┌─────────────────────┐               │
│  │ ai-infer  (VM)      │   │ platform (CT)        │               │
│  │ Ubuntu 24.04        │   │ Docker               │               │
│  │ GTX 1050 Ti (VFIO)  │   │ demo-api container    │               │
│  │ Ollama :11434       │   │ :8000                │               │
│  │ 10.10.10.120        │   │ 10.10.10.121         │               │
│  └─────────┬───────────┘   └─────────┬───────────┘               │
│            │ Ollama (private net)    │                           │
│            ▼                         ▼                           │
│  ┌─────────────────────┐   ┌─────────────────────┐               │
│  │ edge (CT)           │   │ obs (CT)            │               │
│  │ Caddy reverse proxy  │   │ Prometheus+Grafana  │               │
│  │ :80                 │   │ :3000               │               │
│  │ 10.10.10.122        │   │ 10.10.10.123        │               │
│  └─────────────────────┘   └─────────────────────┘               │
│                                                                   │
│  ┌─────────────────────┐                                          │
│  │ runner (LXC)        │  self-hosted GitHub Actions runner       │
│  │ 10.10.10.124        │  (reaches the private lab net)           │
│  └─────────────────────┘                                          │
└───────────────────────────────────────────────────────────────────┘
```

## Fast send

```bash
git clone https://github.com/nivedmahendran/proxmox-ai-platform.git
cd proxmox-ai-platform
```

| What | Where |
|---|---|
| Provision the guests | `terraform/proxmox/` |
| Talos cluster configs | `talos/` |
| Kubernetes GitOps apps | `kubernetes/` |
| AI inference service (API + Ollama) | `ai-inference/` |
| GitHub Actions CI/CD | `.github/workflows/` |
| Architecture & runbooks | `docs/` |

## Live demo endpoints

| Endpoint | URL |
|---|---|
| API health | `http://10.10.10.122/api/health` |
| Chat completion | `http://10.10.10.122/api/chat` |
| Grafana | `http://10.10.10.123:3000` |

```bash
curl -s http://10.10.10.122/api/health
curl -s http://10.10.10.122/api/chat -H 'content-type: application/json' \
  -d '{"message":"Say hello in one sentence."}'
```

## Tech stack

| Layer | Tools |
|---|---|
| Hypervisor | Proxmox VE 9.1 |
| Provisioning | Terraform + proxmox provider |
| Cluster | Talos Linux / Kubernetes (k3s option for lighter) |
| GitOps | ArgoCD |
| Ingress | Caddy (edge) / ingress-nginx (in-cluster) |
| Inference | Ollama on GTX 1050 Ti (VFIO passthrough) |
| API | FastAPI |
| Observability | Prometheus, Grafana, Loki |
| CI/CD | GitHub Actions + self-hosted runner |

## Docs

- [Architecture](docs/architecture.md)
- [GPU passthrough](docs/gpu-passthrough.md)
- [CI/CD](docs/ci-cd.md)
- [Backups & DR](docs/backups.md)
- [Runbooks](docs/runbooks.md)
- [Decision log](docs/decisions.md)

## Status

| Component | State |
|---|---|
| Terraform guests | ✅ provisioned |
| ai-infer (Ollama + GPU) | ✅ running |
| platform (demo-api) | ✅ running |
| edge (Caddy) | ✅ running |
| obs (Prometheus/Grafana) | ✅ running |
| runner (self-hosted GH Actions) | ✅ running |
| CI/CD pipeline | ✅ green |
