data "template_file" "cloudinit_template" {
  template = <<EOF
#cloud-config
fqdn: ${var.vm_domain}
manage_etc_hosts: true
package_update: true
package_upgrade: true
ssh_pwauth: 1
timezone: "America/New_York"
users:
  - name: user
    passwd: $y$j9T$90KTrNAm1VThpSJR99lD/1$V28A3c/tiTBCC1drC6jnu4LVChD1XpcLA2uQ.RD6uXB
    home: /home/user
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    chpasswd: { expire: False }
    groups: sudo, users, admin
EOF

  vars = {
    fqdn = var.vm_domain
  }
}

# upgautamvt@fedora:~/CLionProjects/KernelWithBpfPrograms/benchmarks/macrobenchmarks/terraform/xdp_terraform$ mkpasswd
# Password:password
# $y$j9T$90KTrNAm1VThpSJR99lD/1$V28A3c/tiTBCC1drC6jnu4LVChD1XpcLA2uQ.RD6uXB
