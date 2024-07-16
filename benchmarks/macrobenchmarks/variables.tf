# Host Parameters
variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/var/lib/libvirt/images/ebpf24"
}

# Node Config
variable "vm_baseimage" {
  description = "ubuntu 24.04 image"
  default     = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "client_image" {
description = "image for the client vm"
  default     = "client_root.img"
}

variable "base_image" {
description = "image for the base vm"
  default     = "vanilla_kernel_root.img"
}

variable "xdp_kernel_image" {
description = "image for the naive vm"
  default     = "xdp_kernel_root.img"
}

variable vm_vcpu {
  description = "Number of vCPUs"
  default = 2
}

variable vm_memory {
  description = "Memory in MiB"
  default = 4096
}

variable vm_disksize {
  description = "Disk size in GiB"
  default = 40
}

variable vm_domain {
  description = "FQDN for the network"
  default = "xdp_kernel.local"
}

# VMs
variable vms {
  type = map(any)
}
