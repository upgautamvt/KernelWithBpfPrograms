#  qemu:system is a Uniform Resource Identifier (URI) scheme used by libvirt to
#  specify the connection to the local QEMU/KVM hypervisor running in system mode.?

# this is a libvirt connection
provider "libvirt" {
  uri = "qemu:///system"
}

# A "libvirt pool" refers to a storage pool managed by libvirt, where virtual machine disk images, ISOs,
# and other storage resources can be stored and accessed by virtual machines running on the host.

# this is a storage pool, can be Filesystem directory type, and it holds qcow2 (format qcow2) or img (which are raw format) files
# qcow2 files are type of storage volumes. It means storage pool includes storage volumes
resource "libvirt_pool" "storage_pool" {
  name = "my storage pool"
  type = "dir"
  path = var.libvirt_disk_path # defined in variables.tf
}


# A libvirt volume refers to a logical storage unit managed within a storage pool by the libvirt API and tools.
# It represents a virtual disk image, ISO file, or any other storage
# resource that can be attached to and used by virtual machines (VMs) managed by libvirt.


# all volume resources (e.g., disk) are in same pool libvirt pool

# each libvirt storage pool contains several storage volumes
# all libvirt related resource start with libvirt_ prefix
resource "libvirt_volume" "ubuntu_24_base" {
  name = "ubuntu_24.04"
  source = var.vm_baseimage
  pool = libvirt_pool.storage_pool.name # all storage volumes in same storage pool
}

resource "libvirt_volume" "qcow2-client" {
  name = "client_root.img"
  pool = libvirt_pool.storage_pool.name # all storage volumes in same storage pool
  format = "qcow2"
  source = var.client_image
}

resource "libvirt_volume" "qcow2-vanilla_kernel" {
  name = "vanilla_kernel_root.img"
  pool = libvirt_pool.storage_pool.name # all storage volumes in same storage pool
  format = "qcow2"
  source = var.base_image
}

resource "libvirt_volume" "qcow2-xdp_kernel" {
  name = "xdp_kernel_root.img"
  pool = libvirt_pool.storage_pool.name # all storage volumes in same storage pool
  format = "qcow2"
  source = var.xdp_kernel_image
}



# Manages a cloud-init ISO disk that can be used to customize a domain during first boot.
# libvirt_cloudinit_disk is defined in terraform
resource "libvirt_cloudinit_disk" "cloudinit-client" {
  name = "cloudinit_client.iso"
  pool = libvirt_pool.storage_pool.name
  user_data = <<EOF
#cloud-config
fqdn: client.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $6$.w.RA7.g2CMWN/Zx$eK79F4Aub3PRSP8qdMKaaDe7S/deyy38bmlKAtjOJosN5o2Orb/gYZCH1f1LXPI5wpJzi.VO9fVkrrx2iEFIU1 
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit-vanilla_kernel" {
  name = "cloudinit_vanilla_kernel.iso"
  pool = libvirt_pool.storage_pool.name
  user_data = <<EOF
#cloud-config
fqdn: vanilla_kernel.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $6$.w.RA7.g2CMWN/Zx$eK79F4Aub3PRSP8qdMKaaDe7S/deyy38bmlKAtjOJosN5o2Orb/gYZCH1f1LXPI5wpJzi.VO9fVkrrx2iEFIU1 
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit-xdp_kernel" {
  name = "cloudinit_xdp_kernel.iso"
  pool = libvirt_pool.storage_pool.name
  user_data = <<EOF
#cloud-config
fqdn: xdp_kernel.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $6$.w.RA7.g2CMWN/Zx$eK79F4Aub3PRSP8qdMKaaDe7S/deyy38bmlKAtjOJosN5o2Orb/gYZCH1f1LXPI5wpJzi.VO9fVkrrx2iEFIU1 
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

# define network
# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.6/website/docs/r/network.markdown
resource "libvirt_network" "net" {
  name      = "net"
  mode      = "nat"
  domain    = var.vm_domain
  addresses = ["192.168.64.0/24"]
  dhcp {
    enabled = false
  }
  dns {
    enabled    = true
    local_only = false
  }
}


# this is like actual vm
resource "libvirt_domain" "domain-client" {
  name   = "client"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-client.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = "client"
    addresses      = ["192.168.64.2"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.qcow2-client.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain-vanilla_kernel" {
  name   = "vanilla_kernel"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-vanilla_kernel.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = "vanilla_kernel"
    addresses      = ["192.168.64.3"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.qcow2-vanilla_kernel.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain-xdp_kernel" {
  name   = "xdp_kernel"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-xdp_kernel.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = "xdp_kernel"
    addresses      = ["192.168.64.4"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.qcow2-xdp_kernel.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
