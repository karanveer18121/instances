data "terraform_remote_state" "network_details" {
  backend = "s3"
  config = {
    bucket = "student.18-gagankaran-bucket"
    key    = "student.18-network-state"
    region = "ap-south-1"
  }
}

module "webserver" {
  source = "./modules/linux_node"
  ami           = "ami-02d26659fd82cf299"
  subnet_id     = data.terraform_remote_state.network_details.outputs.my_subnet
  key_name      = data.terraform_remote_state.network_details.outputs.key_name
  vpc_security_group_ids = data.terraform_remote_state.network_details.outputs.security_group_id_array
  instance_type = "t3.micro"

  tags = {
    Name = "student.18-vm1"
  }
}
