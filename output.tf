output "public_ip" {
  value = aws_instance.my_vm.public_ip
}
output "security_group_id_array" {
value = aws_security_group.open_ports.*.id
}
