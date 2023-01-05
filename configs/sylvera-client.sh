fetch() {

  local environment="$1"
  local endpoint="$2"
  local filters="$3"

  if [[ "$SERVER_KEY" == "" ]]; then 
    echo 'Error: you must set $SERVER_KEY env variable with the value of API key you want to use.'
    return 0;
  fi;

  if [[ "$endpoint" == "" ]]; then 
    echo 'Error: you must specify endpoint you want to query as a second arg. Params are allowed.'
    return 0;
  fi;

  if ! [[ $environment =~ (dev|staging|preview|production) ]]; then 
    echo 'Error: you must specify an environment as a first arg. Permitted values: dev, staging, preview, production'
    return 0;
  fi;

  # if --to-file is not present, colour the output
  # else do not colour, as this break writing input to a file by including
  # colour codes
  if [[ "$4" == "--to-file" ]]; then 
    local to_stdin=''
  else
    local to_stdin='-C'
  fi;

  
  if [[ $environment == "production" ]]; then
      accessToken=$(http --all -j POST https://api.sylvera.com/auth/tokens Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey":'"$SERVER_KEY"'}}' | jq -r '.data.attributes.accessToken')
      result=$(http --all -j -A bearer --auth "$accessToken" GET https://api.sylvera.com/$endpoint Content-Type:application/vnd.api+json | jq $to_stdin -r $filters)
      echo $result
      return 0
  fi

      accessToken=$(http --all -j POST "https://api.$environment.sylvera.com/auth/tokens" Content-Type:application/vnd.api+json data:='{"id": "string", "type": "apiTokens", "attributes": {"apiKey": '"$SERVER_KEY"'}}' | jq -r '.data.attributes.accessToken')
      result=$(http --all -j -A bearer --auth "$accessToken" GET https://api.$environment.sylvera.com/$endpoint Content-Type:application/vnd.api+json | jq $to_stdin -r $filters)
      echo $result
      return 0
      
}

