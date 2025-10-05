# Get the ssh key from a local file
data "local_file" "ssh_public_key" {
  filename = "./id_rsa.pub"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "NFS"
  node_name    = "proxmox01"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)} # this is needed to remove any trailing character
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - timedatectl set-timezone America/New_York
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "vm-name" {
  name        = "test"
  description = "Managed by Terraform"
  node_name   = "proxmox01"

  # Set QEMU agent enable
  agent {
    enabled = true
  }

  # Specify the template you want to clone
  clone {
    datastore_id = "iSCI-LVM"
    vm_id        = 102
  }

  # Set VM CPU details
  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
    units = 100
  }

  # Set VM storage details. You can add one or more disk section for more virtual HDD
  disk {
    datastore_id = "iSCI-LVM"
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
  }

  # Set the VM NIC. You can add one or more network_device section for more NICs
  network_device {
    bridge = "vmbr0"
  }

  # Set VM ram
  memory {
    dedicated = 2048
  }

  # Set Cloud-Init data
  initialization {
    datastore_id = "NFS"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    # the proxmox_virtual_environment_file resource you created above
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
}
