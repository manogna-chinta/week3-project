terraform {
  backend "s3" {
    bucket = "manogna-terraform-remote-state"
    key    = "manogna-website.tfstate"
    region = "us-east-1"
    profile = "default"
  }
}