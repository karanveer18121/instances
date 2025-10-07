data "terraform_remote_state" "network_details" {
  backend = "s3"
  config = {
    bucket = "student.18-gagankaran-bucket"
    key    = "student.18-network-state"
    region = "ap-south-1"
  }
}
