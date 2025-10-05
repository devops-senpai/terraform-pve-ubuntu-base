terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.1"
    }
  }
}
provider "proxmox" {
  endpoint  = "https://proxmox01:8006/api2/json"
  insecure  = true
  api_token = var.api_token
  ssh {
    agent    = true
    username = "terraform"
  }
}
