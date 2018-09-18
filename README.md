# Terraforming 🌱→🤖🔬 tinyrobot.science

*Based on [Confluent's Terraform config with S3 state storage](https://github.com/confluentinc/terraform-state-s3).*

### Part of a reference suite

| Terraform config | [Web UI](https://github.com/mars/tinyrobot-science-web-ui) | [API](https://github.com/mars/tinyrobot-science-api) |
|-----------|------------|---------|
| infrastructure (this repo) | front-end app | backend app |

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
* Identify the build pipeline for each app. Pipeline UUIDs can be found by visiting each pipeline used to build the slugs in the [Heroku Dashboard](https://dashboard.heroku.com/) and copying them from the page address/URL:

  ```bash
  export \
    BUILD_PIPELINE_API=2f557b76-d685-452a-8651-9a6295a2a032 \
    BUILD_PIPELINE_WEB_UI=26a3ecbf-8188-43ae-b0fe-be2d9e9fe26f
  ```
* Setup the unique identifiers for the apps. The team name & DNS host names must already be exist:

  ```bash
  export \
    TF_VAR_heroku_team_name=tinyrobot-science \
    TF_VAR_api_host_name=api.tinyrobot.science \
    TF_VAR_ui_host_name=tinyrobot.science
  ```
* Provision the configuration:

  ```bash
  cd environments/dev
  terraform init
  
  # Capture the pipelines' current Slug IDs
  source ../../bin/pipeline-slug-ids
  
  terraform plan
  terraform apply
  ```
* Output includes the DNS CNAME targets for the host names.
