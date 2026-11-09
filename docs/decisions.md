# Decision log — the "why" behind design choices. In an interview, this is a
# compelling artifact. Each entry records the problem, the options considered,
# the choice, and the trade-off.

## ADR-001: Self-hosted runner instead of GitHub-hosted
- **Problem:** The lab network (10.10.10.0/22) is private; GitHub-hosted runners
  can't reach it. Deployment steps in earlier projects were "skipped by design".
- **Options:** (a) self-hosted runner on the LAN, (b) Tailscale exit node for the
  runner, (c) open a public port to the lab.
- **Choice:** (a) — a self-hosted runner provisioned as an LXC container.
- **Trade-off:** Runner is on the local network (fine for a homelab); it adds a
  credential + maintenance surface, mitigated by scoping it to one repo.

## ADR-002: Ollama on a GPU-passthrough VM, not a container
- **Problem:** Need deterministic GPU access for inference.
- **Options:** (a) VFIO passthrough to a VM, (b) shared GPU via nvidia-container-toolkit.
- **Choice:** (a) for the dedicated ai-infer VM — simpler, isolated, best latency.
- **Trade-off:** One workload per GPU; no sharing. Acceptable for a single inference service.

## ADR-003: Terraform for Proxmox, not Ansible
- **Problem:** Provision guests reproducibly.
- **Options:** (a) Terraform + proxmox provider, (b) Ansible, (c) manual PVE UI.
- **Choice:** (a) — state tracking, plan/apply cycle, drift detection.
- **Trade-off:** The bpg/proxmox provider is young; pinned to a version and the
  plan is reviewed before apply.

## ADR-004: FastAPI gateway in front of Ollama
- **Problem:** Want a versioned, stable API contract rather than exposing Ollama
  directly.
- **Options:** (a) FastAPI wrapper, (b) plain reverse proxy to Ollama's API.
- **Choice:** (a) — allows validation, health checks, and an abstraction over the
  underlying model/version.
- **Trade-off:** Adds a hop; negligible for a local lab.
