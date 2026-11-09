terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  # API token (recommended over password auth)
  # Create: pveum user token add terraform@pve opencode --privsep 0
  username = var.proxmox_username
  token    = var.proxmox_token
  insecure = var.proxmox_insecure
}

variable "proxmox_endpoint" {
  default = "https://10.10.10.113:8006/"
}

variable "proxmox_username" {
  description = "Proxmox API token owner (e.g. root@pam!opencode-mcp)"
}

variable "proxmox_token" {
  sensitive = true
}

variable "proxmox_insecure" {
  type    = bool
  default = true
}

variable "vm_template_id" {
  description = "VMID of the Ubuntu 24.04 cloud-init template"
  default     = 9000
}

variable "lab_gateway" {
  default = "10.10.10.1"
}

variable "lab_subnet_mask" {
  default = 22
}
