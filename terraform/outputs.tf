data "aws_eip" "web_server" {
  id = "eipalloc-0faeffe3858272e98"
}

output "web_server_private_ip" {
  description = "Private IP address of the web server"
  value       = module.web_server.private_ip
}

output "web_server_public_ip" {
  description = "Elastic IP address of the web server"
  value       = data.aws_eip.web_server.public_ip
}

# Ansible Controller
output "ansible_controller_private_ip" {
  description = "Private IP address of the Ansible controller"
  value       = module.ansible_controller.private_ip
}

output "ansible_controller_public_ip" {
  description = "Public IP address of the Ansible controller (none — private subnet)"
  value       = module.ansible_controller.public_ip
}

# Monitoring Server
output "monitoring_server_private_ip" {
  description = "Private IP address of the monitoring server"
  value       = module.monitoring_server.private_ip
}

output "monitoring_server_public_ip" {
  description = "Public IP address of the monitoring server (none — private subnet)"
  value       = module.monitoring_server.public_ip
}