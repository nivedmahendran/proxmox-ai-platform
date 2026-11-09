---
layout: default
title: Proxmox AI Platform
---
# Proxmox AI Platform

A self-hosted, GitOps-style AI inference platform on Proxmox — one coherent
monorepo that reaches Infrastructure-as-Code, Kubernetes, CI/CD, observability,
and a real GPU/LLM workload.

## Docs

- [Architecture](architecture.md)
- [GPU passthrough](gpu-passthrough.md)
- [CI/CD](ci-cd.md)
- [Backups & DR](backups.md)
- [Runbooks](runbooks.md)
- [Decision log](decisions.md)

## Live stack

| Component | Role |
|---|---|
| `platform` (CT 111) | demo-api (FastAPI) + Ollama |
| `edge` (CT 112) | Caddy reverse proxy |
| `obs` (CT 113) | Prometheus + Grafana |
| `runner` (CT 114) | self-hosted GitHub Actions runner |

## Repo

[github.com/nivedmahendran/proxmox-ai-platform](https://github.com/nivedmahendran/proxmox-ai-platform)
