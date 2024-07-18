data "template_file" "cloudinit_client" {
  template = data.template_file.cloudinit_template.rendered
  vars = {
    fqdn = "client.${var.vm_domain}"
  }
}
