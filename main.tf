data "terraform_remote_state" "network_details" {
  backend = "s3"
  config = {
    bucket = "student.18-gagankaran-bucket"
    key    = "student.18-network-state"
    region = var.region
  }
}
module "webserver" {
source = "./modules/linux_node"
  instance_count = 0
  ami           = "ami-02d26659fd82cf299"
  subnet_id     = data.terraform_remote_state.network_details.outputs.my_subnet
  key_name      = data.terraform_remote_state.network_details.outputs.key_name
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array
  instance_type = "t3.micro"

  tags = {
  Name = "student.18-webserver-vm" 
  }
}
module "loadbalancer" {
  source = "./modules/linux_node"
  instance_count = 0
  ami = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  key_name = data.terraform_remote_state.network_details.outputs.key_name
  subnet_id = data.terraform_remote_state.network_details.outputs.my_subnet
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array
  tags = { Name = "student.18-loadbalancer-vm" }
}

