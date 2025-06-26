resource "proxmox_lxc" "basic" {
  target_node  = "proxmox-master"
  hostname     = "smb-ct01"
  ostemplate   = "local:vztmpl/debian-12-turnkey-fileserver_18.0-1_amd64.tar.gz"
  password     = var.CONTAINER_PASSWORD
  unprivileged = true

  rootfs {
    storage = "media-storage"
    size    = "100G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  onboot    = "true"
}