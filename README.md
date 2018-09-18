# Terraforming 🌱→🤖🔬 tinyrobot.science

An example collaborative microservices architecture for Heroku, based on two Terraform patterns:

* [Confluent's Terraform config with S3 state storage](https://github.com/confluentinc/terraform-state-s3)
* [Deploy Heroku apps from pipelines using Terraform](https://github.com/mars/terraform-heroku-pipeline-slugs)

### Part of a reference suite

| Terraform config | [Web UI](https://github.com/mars/tinyrobot-science-web-ui) | [API](https://github.com/mars/tinyrobot-science-api) |
|-----------|------------|---------|
| infrastructure (this repo) | front-end app | backend app |

## Requirements

* [Heroku](https://www.heroku.com/home)
  * install [command-line tools (CLI)](https://toolbelt.heroku.com)
  * [an account](https://signup.heroku.com)
  * [a team](https://devcenter.heroku.com/articles/heroku-teams)
* install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* install [Terraform](https://terraform.io)

## Setup

First, setup Terraform's remote state store with Amazon S3 & DynamoDB, so that team members may collaborate free of conflicts:

* Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
  * with Homebrew on macOS: `brew install awscli`
* Create AWS IAM user with *AmazonS3FullAccess* & *AmazonDynamoDBFullAccess*
* Run `aws configure` to set the key & secret credentials for that new IAM user
  * ensure *Default region name* is set to same as the AWS provider region in other environments

```bash
git clone https://github.com/mars/tinyrobot-science-terraform
cd tinyrobot-science-terraform/environments/dev-tfstate
terraform init
terraform apply
git commit terraform.tfstate* -m 'Terraform S3 backend state'
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
* Setup the unique identifiers for the apps. The team name & DNS host names must already exist:

  ✏️ *Modify these Heroku team & DNS host names for your own unqiue deployment. Host names must be at a domain that is registered & under your control.*

  ```bash
  export \
    TF_VAR_heroku_team_name=tinyrobot \
    TF_VAR_api_host_name=api.tinyrobot.science \
    TF_VAR_ui_host_name=tinyrobot.science
  ```
* Provision the configuration:

  ```bash
  cd environments/dev
  terraform init
  
  # Capture the pipelines' current Slug IDs
  source ../../bin/pipeline-slug-ids

  terraform apply
  ```
* Output includes the DNS CNAME targets for the host names. To resolve them, please set these in DNS for each corresponding host name.

  ⏱🔐 Automated SSL/TLS certficates for custom domains may take a few minutes to provision or more if there is a DNS misconfiguration.

  ⚠️ **Set low TTL values (less than five minutes) on these DNS records to avoid delays if problems are encountered.**
