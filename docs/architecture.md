# Architecture

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
│  │ edge (CT)           │   │ observability (CT) │               │
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

## Guests

| Guest | Type | Role | Specs | IP |
|---|---|---|---|---|
| `ai-infer` | VM 110 | Ubuntu 24.04 + NVIDIA + Ollama | 4 vCPU, 8 GB, 60 GB, GPU passthrough | 10.10.10.120 |
| `platform` | CT 111 | Docker + demo-api | 2 vCPU, 2 GB, 20 GB | 10.10.10.121 |
| `edge` | CT 112 | Caddy reverse proxy | 1 vCPU, 1 GB, 8 GB | 10.10.10.122 |
| `observability` | CT 113 | Prometheus + Grafana | 2 vCPU, 2 GB, 15 GB | 10.10.10.123 |
| `runner` | CT 114 | self-hosted GitHub Actions runner | 2 vCPU, 2 GB, 20 GB | 10.10.10.124 |

## Networking

- All guests on `vmbr0` / `10.10.10.0/22`, gateway `10.10.10.1`.
- The lab network is **private** — GitHub-hosted runners cannot reach it.
  This is *exactly why* a self-hosted runner exists.

## Data flow

1. `curl http://10.10.10.122/api/chat` → Caddy on edge
2. Caddy reverse-proxies → demo-api container on platform (`:8000`)
3. demo-api parses the request, forwards to Ollama on ai-infer (`:11434`)
4. Ollama (GPU-accelerated) generates the completion, returns it
5. demo-api streams the response back to the client

## Observability

- Prometheus scrapes the node, the demo-api container, and Ollama metrics.
- Grafana visualizes: GPU utilization, inference latency, request rate, node CPU/RAM.
