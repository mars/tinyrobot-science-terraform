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

resource "heroku_addon" "papertrail_ui_staging" {
  app  = "${heroku_app.api_staging.name}"
  plan = "papertrail:choklad"
}

resource "heroku_app" "api_production" {
  name   = "${var.heroku_team_name}-api-production"
  region = "us"
  acm    = true

  organization = {
    name = "${var.heroku_team_name}"
  }
}

resource "heroku_addon" "papertrail_ui_production" {
  app  = "${heroku_app.api_production.name}"
  plan = "papertrail:choklad"
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

resource "heroku_app_release" "api_staging" {
  app     = "${heroku_app.api_staging.name}"
  slug_id = "${var.api_slug_staging}"
}

resource "heroku_formation" "api_staging" {
  app        = "${heroku_app.api_staging.name}"
  type       = "web"
  quantity   = 1
  size       = "standard-1x"
  depends_on = ["heroku_app_release.api_staging"]
}

resource "heroku_pipeline_coupling" "api_production" {
  app      = "${heroku_app.api_production.name}"
  pipeline = "${heroku_pipeline.api.id}"
  stage    = "production"
}

resource "heroku_app_release" "api_production" {
  app     = "${heroku_app.api_production.name}"
  slug_id = "${var.api_slug_production}"
}

resource "heroku_formation" "api_production" {
  app        = "${heroku_app.api_production.name}"
  type       = "web"
  quantity   = 2
  size       = "standard-1x"
  depends_on = ["heroku_app_release.api_production"]
}

### UI

# Create Heroku apps for staging and production
resource "heroku_app" "ui_staging" {
  name   = "${var.heroku_team_name}-ui-staging"
  region = "us"

  organization = {
    name = "${var.heroku_team_name}"
  }

  config_vars = {
    API_URL = "https://${heroku_app.api_staging.name}.herokuapp.com"
  }
}

resource "heroku_addon" "papertrail_api_staging" {
  app  = "${heroku_app.ui_staging.name}"
  plan = "papertrail:choklad"
}

resource "heroku_app" "ui_production" {
  name   = "${var.heroku_team_name}-ui-production"
  region = "us"
  acm    = true

  organization = {
    name = "${var.heroku_team_name}"
  }

  config_vars = {
    API_URL = "https://${var.api_host_name}"
  }
}

resource "heroku_addon" "papertrail_api_production" {
  app  = "${heroku_app.ui_production.name}"
  plan = "papertrail:choklad"
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

resource "heroku_app_release" "ui_staging" {
  app     = "${heroku_app.ui_staging.name}"
  slug_id = "${var.ui_slug_staging}"
}

resource "heroku_formation" "ui_staging" {
  app        = "${heroku_app.ui_staging.name}"
  type       = "web"
  quantity   = 1
  size       = "standard-1x"
  depends_on = ["heroku_app_release.ui_staging"]
}

resource "heroku_pipeline_coupling" "ui_production" {
  app      = "${heroku_app.ui_production.name}"
  pipeline = "${heroku_pipeline.ui.id}"
  stage    = "production"
}

resource "heroku_app_release" "ui_production" {
  app     = "${heroku_app.ui_production.name}"
  slug_id = "${var.ui_slug_production}"
}

resource "heroku_formation" "ui_production" {
  app        = "${heroku_app.ui_production.name}"
  type       = "web"
  quantity   = 2
  size       = "standard-1x"
  depends_on = ["heroku_app_release.ui_production"]
}
