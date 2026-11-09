# -----------------------------------------------------------------------------
# ai-infer VM — GPU-accelerated inference (Ollama)
# -----------------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "ai_infer" {
  name      = "ai-infer"
  node_name = "pve"
  vm_id     = 110
  started   = true

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    size         = 60
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
  }

  # Cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "10.10.10.120/${var.lab_subnet_mask}"
        gateway = var.lab_gateway
      }
    }
    dns {
      servers = ["10.10.10.1", "1.1.1.1"]
    }
    user_account {
      username = "ubuntu"
      keys     = var.ssh_public_keys
    }
  }

  # GPU passthrough — PCI device 02:00.0 (GTX 1050 Ti) + 02:00.1 (audio)
  hostpci {
    device = "0000:02:00.0"
    id     = "hostpci0"
  }
  hostpci {
    device = "0000:02:00.1"
    id     = "hostpci1"
  }
}

variable "ssh_public_keys" {
  type    = list(string)
  default = []
}
