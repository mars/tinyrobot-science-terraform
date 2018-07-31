terraform {
  backend "s3" {
    bucket         = "tinyrobot-science-terraform-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tinyrobot_science_terraform_dev"
  }
}

provider "heroku" {
  version = "~> 1.2"
}

### API

# Create Heroku apps for staging and production
resource "heroku_app" "api_staging" {
  name   = "${var.heroku_team_name}-api-staging"
  region = "us"

  organization = {
    name = "${var.heroku_team_name}"
  }
}

resource "heroku_app" "api_production" {
  name   = "${var.heroku_team_name}-api-production"
  region = "us"
  acm    = true

  organization = {
    name = "${var.heroku_team_name}"
  }
}

# Associate a custom domain for production
resource "heroku_domain" "api" {
  app      = "${heroku_app.api_production.name}"
  hostname = "${var.api_host_name}"
}

# Create a Heroku pipeline
resource "heroku_pipeline" "api" {
  name = "api"
}

# Couple apps to different pipeline stages
resource "heroku_pipeline_coupling" "api_staging" {
  app      = "${heroku_app.api_staging.name}"
  pipeline = "${heroku_pipeline.api.id}"
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "api_production" {
  app      = "${heroku_app.api_production.name}"
  pipeline = "${heroku_pipeline.api.id}"
  stage    = "production"
}

### UI

# Create Heroku apps for staging and production
resource "heroku_app" "ui_staging" {
  name   = "${var.heroku_team_name}-ui-staging"
  region = "us"

  organization = {
    name = "${var.heroku_team_name}"
  }
}

resource "heroku_app" "ui_production" {
  name   = "${var.heroku_team_name}-ui-production"
  region = "us"
  acm    = true

  organization = {
    name = "${var.heroku_team_name}"
  }
}

# Associate a custom domain for production
resource "heroku_domain" "ui" {
  app      = "${heroku_app.ui_production.name}"
  hostname = "${var.ui_host_name}"
}

# Create a Heroku pipeline
resource "heroku_pipeline" "ui" {
  name = "web-ui"
}

# Couple apps to different pipeline stages
resource "heroku_pipeline_coupling" "ui_staging" {
  app      = "${heroku_app.ui_staging.name}"
  pipeline = "${heroku_pipeline.ui.id}"
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "ui_production" {
  app      = "${heroku_app.ui_production.name}"
  pipeline = "${heroku_pipeline.ui.id}"
  stage    = "production"
}
