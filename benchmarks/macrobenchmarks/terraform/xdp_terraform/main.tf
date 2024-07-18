provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "kernel_absorb_pool" {
  name = "kernel_absorb_pool"
  type = "dir"
  path = var.libvirt_disk_path
}

# this denotes official cloud .img file
resource "libvirt_volume" "ubuntu_24_base" {
  name   = "ubuntu_24.04"
  pool   = libvirt_pool.kernel_absorb_pool.name
  format = "qcow2"
  source = var.vm_baseimage
}

# client VM storage volume
resource "libvirt_volume" "qcow2_client" {
  name   = "client_root.img"
  pool   = libvirt_pool.kernel_absorb_pool.name
  format = "qcow2"
  source = var.client_image
}

# base server VM storage volume
resource "libvirt_volume" "qcow2_base" {
  name   = "base_root.img"
  pool   = libvirt_pool.kernel_absorb_pool.name
  format = "qcow2"
  source = var.base_image
}

# xdp server VM storage volume
resource "libvirt_volume" "qcow2_xdp" {
  name   = "xdp_root.img"
  pool   = libvirt_pool.kernel_absorb_pool.name
  format = "qcow2"
  source = var.xdp_image
}

resource "libvirt_cloudinit_disk" "cloudinit_client" {
  name      = "cloudinit_client.iso"
  pool      = libvirt_pool.kernel_absorb_pool.name
  user_data = data.template_file.cloudinit_client.rendered
}

resource "libvirt_cloudinit_disk" "cloudinit_base" {
  name      = "cloudinit_base.iso"
  pool      = libvirt_pool.kernel_absorb_pool.name
  user_data = data.template_file.cloudinit_base.rendered
}

resource "libvirt_cloudinit_disk" "cloudinit_xdp" {
  name      = "cloudinit_xdp.iso"
  pool      = libvirt_pool.kernel_absorb_pool.name
  user_data = data.template_file.cloudinit_xdp.rendered
}

# see https://github.com/dmacvicar/terraform_provider_libvirt/blob/v0.7.6/website/docs/r/network.markdown
resource "libvirt_network" "net" {
  name   = "net"
  mode   = "nat"
  domain = var.vm_domain
  addresses = ["192.168.100.0/24"]
  dhcp {
    enabled = false
  }
  dns {
    enabled    = true
    local_only = false
  }
}

resource "libvirt_domain" "domain_client" {
  name   = "client"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit_client.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = var.vms["client"].hostname
    addresses = var.vms["client"].vm_ip
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
    volume_id = libvirt_volume.qcow2_client.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain_base" {
  name   = "base"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit_base.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = var.vms["base"].hostname
    addresses = var.vms["base"].vm_ip
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
    volume_id = libvirt_volume.qcow2_base.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "domain_xdp" {
  name   = "xdp"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.cloudinit_xdp.id

  network_interface {
    network_name   = "net"
    wait_for_lease = true
    hostname       = var.vms["xdp"].hostname
    addresses = var.vms["xdp"].vm_ip
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
    volume_id = libvirt_volume.qcow2_xdp.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
