resource "heroku_domain" "api" {
  app      = "${heroku_app.api_production.name}"
  hostname = "${var.api_host_name}"
}

resource "heroku_domain" "web_ui" {
  app      = "${heroku_app.web_ui_production.name}"
  hostname = "${var.ui_host_name}"
}
