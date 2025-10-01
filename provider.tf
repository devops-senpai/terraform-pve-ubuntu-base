terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.84.1"
    }
  }
}
provider "proxmox" {
  endpoint = "https://proxmox01:8006/api2/json"
  insecure = true
  api_token = "terraform@pve!provider=1ab05011-1efd-4585-b1f7-e26b6f667611"
  ssh {
    agent    = true
    username = "terraform"
  }
}
