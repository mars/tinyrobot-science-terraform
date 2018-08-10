# Extract slug IDs based on each app's pipeline coupling.
# Requires one argument: the pipeline's latest-releases data
function capture_slug_ids {
  if [ ! -z "$1" ]
  then
    api_pipeline_apps=(`echo $1 | jq -r 'map(.app.id) | unique | @sh'`)
    for ix in ${!api_pipeline_apps[*]}
    do
      eval app_id=${api_pipeline_apps[$ix]} # remove single-quotes
      url="https://api.heroku.com/apps/$app_id/pipeline-couplings"
      >&2 echo "🔸 GET $url"
      coupling_stage=`curl -sS --fail $url -H "Authorization: Bearer $HEROKU_API_KEY" -H "Accept: application/vnd.heroku+json; version=3" -H "Content-Type: application/json" | jq -r '.stage'`
      if [ ! -z "$coupling_stage" ]
      then
        slug_id=`echo "$1" | jq --arg app_id $app_id -r '.[] | select(.app.id == $app_id) | .slug.id'`
        echo "🔹 TF_VAR_api_slug_$coupling_stage=$slug_id"
        eval "export TF_VAR_api_slug_$coupling_stage=$slug_id"
      fi
    done
  fi
}

# The Heroku API key to fetch pipeline & app data.
if [ -z "$HEROKU_API_KEY" ]
then
  >&2 echo "Error: requires HEROKU_API_KEY set to an auth token"
  return
fi

# These are the pipelines used to build the slugs.
if [ -z "$API_BUILD_PIPELINE" ]
then
  >&2 echo "Error: requires API_BUILD_PIPELINE set to a Heroku Pipeline ID"
  return
fi
if [ -z "$WEB_UI_BUILD_PIPELINE" ]
then
  >&2 echo "Error: requires WEB_UI_BUILD_PIPELINE set to a Heroku Pipeline ID"
  return
fi

# Fetch the most recent release data for each pipeline.
>&2 echo "🔸 GET https://api.heroku.com/pipelines/$API_BUILD_PIPELINE/latest-releases"
api_build_pipeline_data=`curl -sS --fail "https://api.heroku.com/pipelines/$API_BUILD_PIPELINE/latest-releases" -H "Authorization: Bearer $HEROKU_API_KEY" -H "Accept: application/vnd.heroku+json; version=3.pipelines" -H "Content-Type: application/json" -H "Range: version ..; order=desc, max=10"`
>&2 echo "🔸 GET https://api.heroku.com/pipelines/$WEB_UI_BUILD_PIPELINE/latest-releases"
web_ui_build_pipeline_data=`curl -sS --fail "https://api.heroku.com/pipelines/$WEB_UI_BUILD_PIPELINE/latest-releases" -H "Authorization: Bearer $HEROKU_API_KEY" -H "Accept: application/vnd.heroku+json; version=3.pipelines" -H "Content-Type: application/json" -H "Range: version ..; order=desc, max=10"`

# Extract slug IDs based on each app's pipeline coupling
capture_slug_ids "$api_build_pipeline_data"
capture_slug_ids "$web_ui_build_pipeline_data"
