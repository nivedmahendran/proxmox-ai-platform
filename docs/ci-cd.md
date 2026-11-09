# CI/CD

Two GitHub Actions workflows drive delivery. The critical design point: a
**self-hosted runner** lives on the lab network because GitHub's hosted runners
cannot reach the private `10.10.10.0/22`.

## ci.yml (on PR / push)
- Lint + import-check the FastAPI app.
- Smoke-test the `/api/health` route.
- Build the demo-api container image (with BuildKit cache).

## deploy.yml (on push to main)
- Runs on `self-hosted` (the runner on the lab network).
- SSHes to the platform guest (10.10.10.121) and runs `docker compose up -d --build`.

## Secrets
| Secret | Used by | Value |
|---|---|---|
| `PLATFORM_HOST` | deploy | `10.10.10.121` |
| `PLATFORM_SSH_KEY` | deploy | private SSH key trusted by platform guest |

## Self-hosted runner
- Provisioned as an LXC container (`runner`, IP 10.10.10.124).
- Installed via `scripts/install-runner.sh`.
- Registered to this repository with label `self-hosted`.
