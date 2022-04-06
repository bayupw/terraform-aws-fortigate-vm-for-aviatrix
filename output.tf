output "fortigate_public_ip" {
  value = aws_eip.this.public_ip
}

output "fortigate_instance_id" {
  value = aws_instance.this.id
}

output "fortigate_port1_egress_private_ip" {
  value = aws_network_interface.port1_egress.private_ip
}

output "fortigate_port2_lan_private_ip" {
  value = aws_network_interface.port2_lan.private_ip
}

output "fortigate_lan_gateway_ip" {
  value = cidrhost(data.aws_subnet.lan_subnet.cidr_block, 1)
}

output "fortigate_public_ip_admin_password" {
  value = "http://${aws_eip.this.public_ip} admin/${var.fw_admin_password}"
}