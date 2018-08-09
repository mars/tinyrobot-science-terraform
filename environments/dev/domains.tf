resource "heroku_domain" "api" {
  app      = "${heroku_app.api_production.name}"
  hostname = "${var.api_host_name}"
}

resource "heroku_domain" "ui" {
  app      = "${heroku_app.ui_production.name}"
  hostname = "${var.ui_host_name}"
}
