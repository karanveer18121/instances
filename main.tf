# ----------------------------
# Remote state configuration
# ----------------------------
data "terraform_remote_state" "network_details" {
  backend = "s3"
  config = {
    bucket = "student.18-gagankaran-bucket"
    key    = "student.18-network-state"
    region = var.region
  }
}

# ----------------------------
# Web Server Module
# ----------------------------
module "webserver" {
  source = "./modules/linux_node"
  instance_count = 0
  ami = "ami-02d26659fd82cf299"
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array
  instance_type = "t3.micro"

  tags = {
    Name = var.webserver_prefix
  }

  install_package = "webservers"
  playbook_name   = "install-apache.yaml"
}

# ----------------------------
# Load Balancer Module
# ----------------------------
module "loadbalancer" {
  source = "./modules/linux_node"
  instance_count = 0
  ami = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array

  tags = {
    Name = var.loadbalancer_prefix
  }

  install_package = "load_balancer"
  playbook_name   = "install-ha-proxy.yaml"

  depends_on = [module.webserver]
}

# ----------------------------
# Docker Host Module
# ----------------------------
module "web_docker_host" {
  source = "./modules/linux_node"
  instance_count = 0
  ami = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array

  tags = {
    Name = var.web_docker_host_prefix
  }

  install_package = "dockerhost"
  playbook_name   = "install-docker.yaml"
}

module "lb_docker_host" {
  source = "./modules/linux_node"
  instance_count = 0
  ami = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array

  tags = {
    Name = var.lb_docker_host_prefix
  }

  install_package = "loadbalancer_docker"
  playbook_name   = "install-lb-docker-host.yaml"

  depends_on = [module.web_docker_host]
}
module "jenkins_master" {
  source = "./modules/linux_node"
  instance_count = 1
  ami = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array

  tags = {
    Name = var.jenkins_master_prefix
  }

  install_package = "jenkins"
  playbook_name   = "install-jenkins-master.yaml"
}
