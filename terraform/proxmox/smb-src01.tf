resource "proxmox_vm_qemu" "srv01-smb" {
  name        = "SRV01-SMB"
  target_node = "proxmox-master"

  clone = "ramira-srv01"
}