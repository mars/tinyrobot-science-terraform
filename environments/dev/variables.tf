variable "heroku_team_name" {
  description = "Name of the Heroku Team owning this complete deployment."
  type        = "string"
  default     = "tinyrobot"
}

variable "api_host_name" {
  description = "Fully-qualified DNS name of production API"
  type        = "string"
  default     = "api.tinyrobot.science"
}

variable "ui_host_name" {
  description = "Fully-qualified DNS name of production UI"
  type        = "string"
  default     = "tinyrobot.science"
}
