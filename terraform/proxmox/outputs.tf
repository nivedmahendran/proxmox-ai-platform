# Proxmox AI Platform — Terraform outputs
output "guests" {
  value = {
    ai_infer = "10.10.10.120"
    platform  = "10.10.10.121"
    edge      = "10.10.10.122"
    observability = "10.10.10.123"
    runner    = "10.10.10.124"
  }
}
