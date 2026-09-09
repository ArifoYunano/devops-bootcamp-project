resource "local_file" "inventory" {
  filename = "${path.module}/inventory.ini"

  content = templatefile("${path.module}/inventory.ini.tftpl", {
    web_server_ip         = module.web_server.private_ip
    ansible_controller_ip = module.ansible_controller.private_ip
    monitoring_server_ip  = module.monitoring_server.private_ip
  })
}