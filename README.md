# Terraforming 🌱→🤖🔬 tinyrobot.science

*Based on [Confluent's Terraform config with S3 state storage](https://github.com/confluentinc/terraform-state-s3).*

## Setup

First we'll provision Amazon S3 & DynamoDB for Terraform's remote state store, so that team members may collaborate free of conflicts:

* [Install Terraform](https://www.terraform.io/downloads.html)
* Install AWS CLI: `brew install awscli`
* Create AWS IAM user with *AmazonS3FullAccess* & *AmazonDynamoDBFullAccess*
    * then run `aws configure` to set the key & secret credentials
    * ensure *Default region name* is set to same as the AWS provider region in other environments
* Clone: https://github.com/mars/tinyrobot-science-terraform

```bash
cd environments/dev-tfstate
terraform init
terraform plan
terraform apply
```

## Usage

Once the setup is complete, we'll now switch to the application's Terraform environment, which will use the remote state store for persistence, but is otherwise independent:

* Set Heroku auth as local environment variables: 

  ```bash
  heroku authorizations:create --description tinyrobot-science --short
  export HEROKU_API_KEY=xxxxx
  ```
* Capture the current pipeline releases' slug IDs as `TF_VAR_` variables. The Pipeline UUIDs can be found by visiting each pipeline used to build the slugs in the [Heroku Dashboard](https://dashboard.heroku.com/) and copying them from the page address/URL:

  ```bash
  export API_BUILD_PIPELINE=2f557b76-d685-452a-8651-9a6295a2a032
  export WEB_UI_BUILD_PIPELINE=26a3ecbf-8188-43ae-b0fe-be2d9e9fe26f
  source bin/pipeline-slug-ids.sh
  ```
* Provision the configuration:

  ```bash
  cd environments/dev
  terraform init
  terraform plan
  terraform apply
  ```
* Use `terraform show` to see the cname targets for the custom domain names and configure them (manually) in DNS.
* To re-deploy apps based on the Pipeline releases:

  ```bash
  cd environments/dev
  source ../../bin/pipeline-slug-ids.sh
  terraform plan
  terraform apply
  ```
