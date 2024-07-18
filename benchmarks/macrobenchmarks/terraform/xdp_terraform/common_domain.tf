# common_domain.tf

locals {
  common_memory_vcpu = {
    memory = var.vm_memory
    vcpu   = var.vm_vcpu
  }

  common_console = [
    {
      type        = "pty"
      target_port = "0"
      target_type = "serial"
    },
    {
      type        = "pty"
      target_type = "virtio"
      target_port = "1"
    }
  ]

  common_graphics = {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}