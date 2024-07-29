# terraform.tfvars is a file where you provide values for the variables defined in variables.tf.
# This file is used to set or override the default values of variables.

# Purpose
  # Assign Values: You use terraform.tfvars to assign actual values to the variables that were declared in variables.tf.
  # Override Defaults: If a variable has a default value in variables.tf, the value in terraform.tfvars will override it.
  # Provide Environment-Specific Configurations: You can use this file to specify different values
  # for different environments or scenarios.

# VM Configurations
vms = {
  xdp = {
    hostname = "xdp"
    vm_ip     = ["192.168.100.2"]
  },
  base = {
    hostname = "base"
    vm_ip     = ["192.168.100.3"]
  },
  client = {
    hostname = "client"
    vm_ip     = ["192.168.100.4"]
  },
}

# Node Configuration Parameters
vm_vcpu      = 2
vm_memory    = 4096  # Memory in MiB
vm_disksize  = 40    # Disk size in GiB
vm_domain    = "local"

# VM Image Paths
vm_baseimage = "images/ubuntu-24.04-server-cloudimg-amd64.img"
client_image = "images/client_root.img"
base_image   = "images/base_root.img"
xdp_image     = "images/xdp_root.img"

# Host Parameters
libvirt_disk_path = "/var/lib/libvirt/images/kernel_absorb"
