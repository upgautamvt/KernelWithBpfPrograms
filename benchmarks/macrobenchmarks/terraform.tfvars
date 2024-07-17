#VMs
vms = {
moo-client = {
    hostname: "moo-client"
    vm_ip: ["192.168.64.2"]
  },
moo-base = {
    hostname: "moo-base"
    vm_ip: ["192.168.64.3"]
  },
moo-naive = {
    hostname: "moo-naive"
    vm_ip: ["192.168.64.4"]
  },
}

# Node Config
vm_vcpu = 2
vm_memory = 4096
vm_disksize = 40 # In GiB.
vm_domain = "moo.local"
vm_baseimage = "https://cloud-images.ubuntu.com/releases/24.04/release-20240423/ubuntu-24.04-server-cloudimg-amd64.img"
moo_client_image = "images/moo-client_root.img"
moo_base_image = "images/moo-base_root.img"
moo_naive_image = "images/moo-naive_root.img"

# Host Parameters
libvirt_disk_path = "/var/lib/libvirt/images/ebpf24-moo"
