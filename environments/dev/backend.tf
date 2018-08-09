terraform {
  backend "s3" {
    bucket         = "tinyrobot-science-terraform-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tinyrobot_science_terraform_dev"
  }
}
