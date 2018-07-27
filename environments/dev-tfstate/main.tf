provider "aws" {
  region  = "us-east-1"
  version = "~> 1.29"
}

module "dev-tfstate" {
  source = "git@github.com:mars/terraform-state-s3.git"
  env = "dev"
  s3_bucket = "tinyrobot-science-terraform-dev"
  s3_bucket_name = "Terraform State Store"
  dynamodb_table = "tinyrobot_science_terraform_dev"
}