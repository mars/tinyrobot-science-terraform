output "api_cname" {
  value = "${heroku_domain.api.cname}"
}

output "web_ui_cname" {
  value = "${heroku_domain.web_ui.cname}"
}
