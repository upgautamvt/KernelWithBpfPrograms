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
# they are used to pass user data other metadata to VMs.
# they are used for setups

# Standard definition as,
# resource "libvirt_cloudinit_disk" "commoninit" {
#   name       = "commoninit.iso"
#   user_data  = file("cloud_init.cfg")
#   meta_data  = file("meta_data.cfg")
#   network_config = file("network_config.cfg")
# }


#  because of true it makes /etc/hosts in VM like,
  #  127.0.0.1   localhost
  #  192.168.1.100 client.local client

resource "libvirt_cloudinit_disk" "cloudinit-client" {
  name = "cloudinit_client.iso"
  pool = libvirt_pool.storage_pool.name # iso image is also in the same storage pool
  user_data = <<EOF
#cloud-config
fqdn: client.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: user1
    passwd: password1
    home: /home/user1
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

# <<EOF is a heredoc syntax that allows to include multiline string
# cloud-config is a standard header used by cloud-init to identify the content format.
# enable ssh login using password ssh_pwauth
# package_update means apt get upgrade
# manage_etc_hosts = true means cloud-init configuration is used to update /etc/hosts of VM

# below two lines are part of the cloud-init config
# fqdn: vanilla_kernel.${var.vm_domain}
# manage_etc_hosts: true
#  because of true it makes /etc/hosts in VM like,
  #  127.0.0.1   localhost
  #  192.168.1.100 vanilla_kernel.local vanilla_kernel

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
  - name: user1
    passwd: password1
    home: /home/user1
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
  - name: user1
    passwd: password1
    home: /home/user1
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

# define network
# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.6/website/docs/r/network.markdown
# local_only = false: This setting allows DNS queries to be forwarded
# to external DNS servers if they cannot be resolved locally.
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


# libvirt_domain is actually a VM
resource "libvirt_domain" "domain-client" {
  name   = "client"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  # you don't see id here, but when we do terraform plan, it will have id
  # defined for libvirt_cloudinit_disk.cloudinit-client object
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

  # this console device emulates serial port
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # pty means pseudo-terminal allows to connect to VM through terminal console
  # "virtio": Virtio is a virtualization standard for network and disk
  # device drivers. It provides high-performance I/O by para-virtualizing
  # the devices.
  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  disk {
    volume_id = libvirt_volume.qcow2-xdp_kernel.id
  }

  # using vm display output via SPICE protocol
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
