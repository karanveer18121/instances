terraform {
  backend "s3" {
     bucket = "student.18-gagankaran-bucket"
     key = "student.18-instances-state"
     region = "ap-south-1"
  }
}
