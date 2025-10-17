resource "aws_instance" "my_vm" {
  count = var.instance_count 
  ami = var.ami
  subnet_id = var.subnet_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = var.tags

provisioner "remote-exec" {
  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    agent = false
    private_key = file("/home/ubuntu/terraform_base/keys/student.18-vm-key")
  }
  inline = [
    "sudo apt install -y python3"
  ]
 }
}
resource "local_file" "tf_ansible_inventory" {
  count = length(aws_instance.my_vm) > 0 ? 1 : 0
  content = <<-EOT
[${var.install_package}]
%{ for vm in aws_instance.my_vm.* ~}
${vm.private_dns} ansible_host=${vm.public_ip} ansible_ssh_user=ubuntu
%{ endfor ~}
EOT
  filename = "./tf_ansible_${var.install_package}_inventory.ini"

}
resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_instance.my_vm]
  count = length(aws_instance.my_vm) > 0 ? 1 : 0
  create_duration = "30s"
}
resource "null_resource" "install_package" {
  count      = length(aws_instance.my_vm) > 0 ? 1 : 0
  depends_on = [time_sleep.wait_30_seconds]
provisioner "local-exec" {
  command = <<EOT
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu \
  -i ./tf_ansible_${var.install_package}_inventory.ini \
  ../ansible-playbooks/${var.playbook_name} \
  --private-key="/home/ubuntu/terraform_base/keys/student.18-vm-key"
	EOT
}
provisioner "local-exec" {
  command = "sudo apt-get update -y && sudo apt-get install -y openjdk-17-jdk"
}
}
