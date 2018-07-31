# Terraforming 🌱→🤖🔬 tinyrobot.science

*Based on [Confluent's Terraform config with S3 state storage](https://github.com/confluentinc/terraform-state-s3).*

```bash
curl "https://api.heroku.com/apps/tinyrobot-science-web-ui-build/releases" \
     -H 'Authorization: Bearer xxx-xxx-xxx-xxx' \
     -H 'Accept: application/vnd.heroku+json; version=3' \
     -H 'Content-Type: application/json' \
     -H 'Range: version ..; max=15, order=desc' | jq -r .[0].slug.id
```