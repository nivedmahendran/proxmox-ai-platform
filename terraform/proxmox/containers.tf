locals {
  ct = {
    platform = { id = 111, ip = "10.10.10.121", cores = 2, memory = 2048, disk = 20, tmpl = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst" }
    edge     = { id = 112, ip = "10.10.10.122", cores = 1, memory = 1024, disk = 8,  tmpl = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst" }
    observability = { id = 113, ip = "10.10.10.123", cores = 2, memory = 2048, disk = 15, tmpl = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst" }
    runner   = { id = 114, ip = "10.10.10.124", cores = 2, memory = 2048, disk = 20, tmpl = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst" }
  }
}

resource "proxmox_virtual_environment_container" "guest" {
  for_each = local.ct

  name      = each.key
  node_name = "pve"
  vm_id     = each.value.id
  started   = true

  operating_system {
    template_file_id = each.value.tmpl
    type             = "ubuntu"
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    size         = each.value.disk
  }

  network_interface {
    name  = "eth0"
    bridge = "vmbr0"
  }

  initialization {
    hostname = each.key
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.lab_subnet_mask}"
        gateway = var.lab_gateway
      }
    }
    dns {
      servers = ["10.10.10.1", "1.1.1.1"]
    }
    user_account {
      password = var.ct_root_password
    }
  }
}

variable "ct_root_password" {
  sensitive = true
}
