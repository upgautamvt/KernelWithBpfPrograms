#VMs
vms = {
client = {
    hostname: "client"
    vm_ip: ["192.168.64.2"]
  },
vanilla_kernel = {
    hostname: "vanilla_kernel"
    vm_ip: ["192.168.64.3"]
  },
xdp_kernel = {
    hostname: "xdp_kernel"
    vm_ip: ["192.168.64.4"]
  },
}

# Node Config
vm_vcpu = 2
vm_memory = 4096
vm_disksize = 40 # In GiB.
vm_domain = "xdp_kernel.local"
vm_baseimage = "https://cloud-images.ubuntu.com/releases/24.04/release-20240423/ubuntu-24.04-server-cloudimg-amd64.img"
client_image = "images/client_root.img"
base_image = "images/vanilla_kernel_root.img"
xdp_kernel_image = "images/xdp_kernel_root.img"

# Host Parameters
libvirt_disk_path = "/var/lib/libvirt/images/ebpf24"
