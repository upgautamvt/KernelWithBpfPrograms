provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "moo-pool" {
  name = "moo-pool"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "ubuntu_24_base" {
  name = "ubuntu_24.04"
  source = var.vm_baseimage
  pool = libvirt_pool.moo-pool.name
}

resource "libvirt_volume" "qcow2-moo-client" {
  name = "moo-client_root.img"
  pool = libvirt_pool.moo-pool.name
  format = "qcow2"
  source = var.moo_client_image
}

resource "libvirt_volume" "qcow2-moo-base" {
  name = "moo-base_root.img"
  pool = libvirt_pool.moo-pool.name
  format = "qcow2"
  source = var.moo_base_image
}

resource "libvirt_volume" "qcow2-moo-xdp" {
  name = "moo-xdp_root.img"
  pool = libvirt_pool.moo-pool.name
  format = "qcow2"
  source = var.moo_xdp_image
}

resource "libvirt_cloudinit_disk" "cloudinit-moo-client" {
  name = "cloudinit_moo-client.iso"
  pool = libvirt_pool.moo-pool.name
  user_data = <<EOF
#cloud-config
fqdn: moo-client.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $y$j9T$dFDhqswjBSCIR.D3Tb8GS0$LA/LN/9IfNruT5pKSjk7K76R3r2DI93YF2Lx3rJUGrA
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit-moo-base" {
  name = "cloudinit_moo-base.iso"
  pool = libvirt_pool.moo-pool.name
  user_data = <<EOF
#cloud-config
fqdn: moo-base.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $y$j9T$dFDhqswjBSCIR.D3Tb8GS0$LA/LN/9IfNruT5pKSjk7K76R3r2DI93YF2Lx3rJUGrA
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit-moo-xdp" {
  name = "cloudinit_moo-xdp.iso"
  pool = libvirt_pool.moo-pool.name
  user_data = <<EOF
#cloud-config
fqdn: moo-xdp.${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: 'America/New_York'
users:
  - name: moo
    passwd: $y$j9T$dFDhqswjBSCIR.D3Tb8GS0$LA/LN/9IfNruT5pKSjk7K76R3r2DI93YF2Lx3rJUGrA
    home: /home/moo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF
}

# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.6/website/docs/r/network.markdown
resource "libvirt_network" "moo-net" {
  name      = "moo-net"
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

resource "libvirt_domain" "domain-moo-client" {
  name   = "moo-client"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-moo-client.id

  network_interface {
    network_name   = "moo-net"
    wait_for_lease = true
    hostname       = "moo-client"
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
    volume_id = libvirt_volume.qcow2-moo-client.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain-moo-base" {
  name   = "moo-base"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-moo-base.id

  network_interface {
    network_name   = "moo-net"
    wait_for_lease = true
    hostname       = "moo-base"
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
    volume_id = libvirt_volume.qcow2-moo-base.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain-moo-xdp" {
  name   = "moo-xdp"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit-moo-xdp.id

  network_interface {
    network_name   = "moo-net"
    wait_for_lease = true
    hostname       = "moo-xdp"
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
    volume_id = libvirt_volume.qcow2-moo-xdp.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
