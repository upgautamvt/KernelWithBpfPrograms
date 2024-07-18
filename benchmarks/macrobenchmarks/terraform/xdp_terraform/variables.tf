# variables.tf is a Terraform configuration file where you define variables that will be used throughout
# your Terraform configuration. This file contains variable declarations, including descriptions,
# types, and default values.


# Purpose
  # Declare Variables: You use variables.tf to declare what variables your Terraform configuration requires.
  # Provide Defaults: You can specify default values for variables, which will be used if no other value is provided.
  # Describe Variables: You can include descriptions to explain what each variable is for, which helps with
  # documentation and clarity.

# Host Parameters
variable "libvirt_disk_path" {
  description = "Path for the libvirt pool"
  type        = string
  default     = "/var/lib/libvirt/images/kernel_absorb"
}

# Node Config
variable "vm_baseimage" {
  description = "Path to the Ubuntu 24.04 base image"
  type        = string
  default     = "images/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "client_image" {
  description = "Path to the client VM image"
  type        = string
  default     = "images/client_root.img"
}

variable "base_image" {
  description = "Path to the base VM image"
  type        = string
  default     = "images/base_root.img"
}

variable "xdp_image" {
  description = "Path to the XDP VM image"
  type        = string
  default     = "images/xdp_root.img"
}

variable "vm_vcpu" {
  description = "Number of vCPUs for each VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory in MiB for each VM"
  type        = number
  default     = 4096
}

variable "vm_disksize" {
  description = "Disk size in GiB for each VM"
  type        = number
  default     = 40
}

variable "vm_domain" {
  description = "FQDN for the network"
  type        = string
  default     = "local"
}

# VMs
variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    hostname = string
    vm_ip    = list(string)
  }))
}