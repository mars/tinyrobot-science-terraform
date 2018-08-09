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
* Use `terraform show` to see the cname targets for the custom domain names and configure them (manually) in DNS.

```bash
cd environments/dev

# These are the apps used to build the slugs.
export API_SLUG_BUILD_APP=tinyrobot-science-api-build
export UI_SLUG_BUILD_APP=tinyrobot-science-web-ui-build
# Now fetch the most recent slug IDs as both staging & production.
export TF_VAR_api_slug_staging=`curl "https://api.heroku.com/apps/$API_SLUG_BUILD_APP/releases" -H "Authorization: Bearer $HEROKU_API_KEY" -H "Accept: application/vnd.heroku+json; version=3" -H "Content-Type: application/json" -H "Range: version ..; max=1, order=desc" | jq -r .[0].slug.id`
export TF_VAR_api_slug_production=$TF_VAR_api_slug_staging
export TF_VAR_ui_slug_staging=`curl "https://api.heroku.com/apps/$UI_SLUG_BUILD_APP/releases" -H "Authorization: Bearer $HEROKU_API_KEY" -H "Accept: application/vnd.heroku+json; version=3" -H "Content-Type: application/json" -H "Range: version ..; max=1, order=desc" | jq -r .[0].slug.id`
export TF_VAR_ui_slug_production=$TF_VAR_ui_slug_staging

terraform init
terraform plan
terraform apply
```
