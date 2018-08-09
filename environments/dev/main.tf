provider "heroku" {
  version = "~> 1.2"
}

resource "heroku_pipeline" "api" {
  name = "api"
}

resource "heroku_pipeline" "ui" {
  name = "web-ui"
}
