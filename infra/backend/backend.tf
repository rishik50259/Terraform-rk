terraform {
  backend "s3" {
    bucket = "nexflixterraformbe01"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }
}