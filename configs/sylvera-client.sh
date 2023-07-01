# This is a stupid http client, which can talk to Sylvera API.
#
# Accepts whole range of jq filters as a last argument.
# Is not very performant but is simple to use/amend

function __raise_key_error {
  local key_type="$1"

  echo "Error: you must set $key_type env variable with the value of api key you want to use."
}

function __validate_env {
  local environment="$1"

  if ! [[ $environment =~ (dev|staging|preview|production|local|test) ]]; then
    echo 'Error: you must specify an environment as a first arg. Permitted values: local, dev, staging, preview, test, production'
    kill -INT $$
  fi
}

function __validate_endpoint {
  local endpoint="$1"

  if [[ $endpoint == "" ]]; then
    echo 'Error: you must specify endpoint you want to query as a second arg. Params are allowed.'
    kill -INT $$
  fi
}

function __validate_api_secret {
  local environment="$1"

  if [[ $environment == "production" ]]; then
    if [[ "$SERVER_KEY_PROD" == "" ]]; then
      __raise_key_error '$SERVER_KEY_PROD'
      kill -INT $$
    fi
  fi

  if [[ $environment == "dev" ]]; then
    if [[ "$SERVER_KEY_DEV" == "" ]]; then
      __raise_key_error '$SERVER_KEY_DEV'
      kill -INT $$
    fi
  fi

  if [[ $environment == "test" ]]; then
    if [[ "$SERVER_KEY_TEST" == "" ]]; then
      __raise_key_error '$SERVER_KEY_TEST'
      kill -INT $$
    fi
  fi

  if [[ $environment == "staging" ]]; then
    if [[ "$SERVER_KEY_STAGING" == "" ]]; then
      __raise_key_error '$SERVER_KEY_STAGING'
      kill -INT $$
    fi
  fi

  if [[ $environment == "preview" ]]; then
    if [[ "$SERVER_KEY_PREVIEW" == "" ]]; then
      __raise_key_error '$SERVER_KEY_PREVIEW'
      kill -INT $$
    fi
  fi

  if [[ $environment == "local" ]]; then
    if [[ "$SERVER_KEY_LOCAL" == "" ]]; then

      __raise_key_error '$SERVER_KEY_LOCAL'
      kill -INT $$
    fi
  fi
}

function __exec_http_request {

  local environment="$1"
  local endpoint="$2"
  local http_verb="$3"
  local data="$4"
  local to_stdin="$5"

  if [[ $environment == "local" ]]; then
    accessToken=$(http --all -j POST localhost:8081/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_LOCAL"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" localhost:8081/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi

  if [[ $environment == "dev" ]]; then
    accessToken=$(http --all -j POST https://api.dev.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_DEV"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" https://api.dev.sylvera.com/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi

  if [[ $environment == "production" ]]; then
    accessToken=$(http --all -j POST https://api.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_PROD"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" https://api.sylvera.com/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi

  if [[ $environment == "staging" ]]; then
    accessToken=$(http --all -j POST https://api.staging.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_STAGING"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" https://api.staging.sylvera.com/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi

  if [[ $environment == "preview" ]]; then
    accessToken=$(http --all -j POST https://api.preview.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_PREVIEW"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" https://api.preview.sylvera.com/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi

  if [[ $environment == "test" ]]; then
    accessToken=$(http --all -j POST https://api.test.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":"'"$SERVER_KEY_PREVIEW"'"}}' | jq -r '.data.attributes.accessToken')
    result=$(http --all -j -A bearer --auth "$accessToken" "$http_verb" https://api.test.sylvera.com/$endpoint Content-Type:application/vnd.api+json data:=$data | jq $to_stdin -r $filters)
    echo $result
    return 0
  fi
}

get() {

  local environment="$1"
  local endpoint="$2"
  local filters="$3"
  local to_stdin=''
  local http_verb="GET"
  if [[ "$4" != "--to-file" ]]; then
    local to_stdin='-C'
  fi

  __validate_env $environment
  __validate_endpoint $endpoint
  __validate_api_secret $environment

  __exec_http_request $environment $endpoint $http_verb '{}' $to_stdin
}

post() {

  local environment="$1"
  local endpoint="$2"
  local data="$3"
  local filters="$4"
  local http_verb="POST"
  if [[ "$data" == "" ]]; then
    local data='{}'
  fi
  if [[ "$5" == "--to-file" ]]; then
    local to_stdin=''
  else
    local to_stdin='-C'
  fi

  __validate_env $environment
  __validate_endpoint $endpoint
  __validate_api_secret $environment

  __exec_http_request $environment $endpoint $http_verb $data $to_stdin
}

delete() {

  local environment="$1"
  local endpoint="$2"
  local data="$3"
  local filters="$4"
  local http_verb="DELETE"
  local to_stdin=''
  if [[ "$data" == "" ]]; then
    local data='{}'
  fi
  if [[ "$5" != "--to-file" ]]; then
    local to_stdin='-C'
  fi

  __validate_env $environment
  __validate_endpoint $endpoint
  __validate_api_secret $environment

  __exec_http_request $environment $endpoint $http_verb $data $to_stdin
}
