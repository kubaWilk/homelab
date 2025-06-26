# Ubuntu Server 25.04

#Plugins
packer {
  required_plugins {
    name = {
      version = " >= 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

source "proxmox-iso" "ubuntu-server" {

  # Proxmox Connection Settingsp
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  node    = "proxmox-master"
  vm_id   = "105"
  vm_name = "ramira-srv01"

  boot_iso {
    iso_file = "local:iso/Ubuntu2504.iso"
    # iso_url          = "https://releases.ubuntu.com/25.04/ubuntu-25.04-live-server-amd64.iso"
    iso_checksum     = "8b44046211118639c673335a80359f4b3f0d9e52c33fe61c59072b1b61bdecc5"
    iso_storage_pool = "local"
  }

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size         = "30G"
    format            = "raw"
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm"
    type              = "virtio"
  }
  os = "l26"
  machine="q35"
  cores  = "2"
  memory = "2048"
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # PACKER Boot Commands
  boot_command = [
    "e<wait><down><down><down><end> autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<F10>"
  ]
  boot_wait = "10s"

  # PACKER Autoinstall Settings
  http_directory = "http"

  ssh_username = "ramiradmin"
#   ssh_password = "password"
  ssh_private_key_file = "/home/kuba/.ssh/cloudinit_id_rsa"
  ssh_timeout = "10m"
}

# Build Definition to create the VM Template
build {
  name    = "ubuntu-server"
  sources = ["source.proxmox-iso.ubuntu-server"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt-get -y autoremove --purge",
      "sudo apt-get -y clean",
      "sudo apt-get -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  # Add additional provisioning scripts here
  # ...
}