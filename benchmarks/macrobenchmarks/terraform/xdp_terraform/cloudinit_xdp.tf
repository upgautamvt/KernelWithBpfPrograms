data "template_file" "cloudinit_xdp" {
  template = data.template_file.cloudinit_template.rendered
  vars = {
    fqdn = "xdp.${var.vm_domain}"
  }
}
