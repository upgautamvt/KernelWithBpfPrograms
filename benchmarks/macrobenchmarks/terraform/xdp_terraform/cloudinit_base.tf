data "template_file" "cloudinit_base" {
  template = data.template_file.cloudinit_template.rendered
  vars = {
    fqdn = "base.${var.vm_domain}"
  }
}
