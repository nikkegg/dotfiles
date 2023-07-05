# zsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="obraun"
ZSH_DISABLE_COMPFIX=true
HIST_STAMPS="dd.mm.yyyy"
COMPLETION_WAITING_DOTS="true"
ZVM_VI_ESCAPE_BINDKEY=jk
EDITOR='vim'
export PAGER='vim -c PAGER -'
export MANPAGER="vim -c ASMANPAGER -"
# Exports
export ZSH="${HOME}/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!{.git,.svn,.hg,node_modules,.dump,.sql,.cjs.js,cjs.js.map,.esm.js,.esm.js.map}'"
export FZF_CTRL_R_OPTS="--preview=''"
export FZF_ALT_C_OPTS="--preview='tree -C {} | head -200'"
export VIM_RG="rg --column --line-number --no-heading --color=always --smart-case --glob '!{.git,node_modules}'"
export RIPGREP_CONFIG_PATH="$HOME/dotfiles/configs/.ripgreprc"
# Make homebrew work on Apple Silicone
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ANALYTICS=1
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Prevent zsh from auto-naming tmux windows
export DISABLE_AUTO_TITLE="true"
# Testing zsh config
# Plugins
plugins=(z zsh-vi-mode gitfast common-aliases zsh-syntax-highlighting zsh-autosuggestions)
# Aliases
alias vim="PAGER=bat vim -S ~/.vimrc"
alias gst='git status'
alias gc='git commit'
alias gco='git checkout'
alias ga='git add -p'
alias ..='cd ..'
alias gfp='git push --force-with-lease'
alias git='PAGER=bat hub'
alias f="fzf --preview='bat --color=always --style=numbers {}' --bind shift-up:preview-up,shift-down:preview-down"
alias configs='vim -c "cd ${HOME}/dotfiles" ${HOME}/dotfiles'
alias notes='vim -c "cd ${HOME}/notes" ${HOME}/notes'
alias tm='tmux'
alias cl='clear'
alias pgcli='PAGER=less pgcli'
alias tree="tree -C --dirsfirst"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias export=' export'
# This pipes output of z command (most commonly visited directories) to fzf
j() {
    [ $# -gt 0 ] && z "$*" && return
    cd "$(z -l 2>&1 | fzf --preview '' --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

id_from_cognito_key () {
  node -e "const {stringify } = require('uuid'); console.log(stringify(Uint8Array.from(Buffer.from('$1', 'base64'))))"
}

 __validate_aws_env () {
  local environment="$1"

  if ! [[ $environment =~ (dev|staging|preview|prod|"test") ]]; then
    echo 'Error: you must specify an environment as a first arg. Permitted values: local, dev, staging, preview, test, prod.'
    kill -INT $$
  fi
}

 __validate_lambda_entity () {
  local entity="$1"

  if ! [[ $entity =~ (^project$|^issuance$|^pricing$|^ngeo$) ]]; then
    echo 'Error: you must specify entity to update as a second arg. Permitted values are project, issuance, pricing, ngeo'
    kill -INT $$
  fi
}


tail_logs () {
  local environment="$1"
  local log_group="$2"
  
  __validate_aws_env $environment

  if [[ $log_group == "" ]]; then
    log_group="/ecs/app-api"
  fi

  echo "Tailling $log_group logs in $environment..."

  if [[ $log_group =~ 'lambda' ]]; then
    aws logs tail --follow "$log_group" --profile=$environment
  else
    aws logs tail --follow "$log_group" --profile=$environment | cut -f '3-' -d ' ' | pino-pretty --ignore id --translateTime 'SYS:HH:MM:ss' --singleLine
  fi
}

invoke_etl_lambda () {
  local environment="$1"
  local entity="$2"
  local outputDest="$HOME/lambdaResponse.json"

  __validate_aws_env $environment

  if [[ $entity == "" ]]; then
    entity="project"
  fi

  __validate_lambda_entity $entity


  echo "Invoking ETL lambda in $environment for all $entity entities..."
  echo "Output will be written to $outputDest\n"
  aws lambda invoke \
    --function-name $ETL_LAMBDA \
    --payload '{
  "Records": [
    {
      "messageAttributes": {
        "type": {
          "dataType": "String",
          "stringValue": "all"
        },
        "entity": {
          "dataType": "String",
          "stringValue": "'$entity'"
        }
      }
    }
  ]
}' --cli-binary-format raw-in-base64-out $outputDest --profile=$environment
}

function deactivate_sylvera_user {
  local emailAddress="$1";
  local environments=('development' 'staging' 'production' 'test' 'preview');
  for env in $environments;
    do echo "Deactivating user in $env"; ~/code/user-management/admin-scripts/sylvera users deactivate -e $env --email $emailAddress; 
  done;
}
# This allows to use rg to grep files name. Second arg is path to grep in
# First arg is grep pattern, second optional arg is a directory
rgf() {
  if [ -z "$2" ]
  then
      rg --files | rg "$1"
  else
      rg --files "$2" | rg "$1"
  fi
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

weather () {
    curl "https://wttr.in/${1}"
}

kill_on_port() {
  if [ $# -lt 1 ]
    then
      echo "Valid port number required"
      return
  fi
  kill -9 $(lsof -t -i:"$1")
}

#Editor
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | pbcopy
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/sylvera-client.sh ] && source ~/sylvera-client.sh
#Below stop zsh-vi-mode conflicting with fzf bindings
function integrate_zsh_vi_mode_with_fzf() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  bindkey -s '^e' 'vim $(fzf)\n'
} 

zvm_after_init_commands+=(integrate_zsh_vi_mode_with_fzf)
source "$ZSH/oh-my-zsh.sh"
unsetopt hist_verify
# Do not commit command starting with whitespace to zsh history
setopt HIST_IGNORE_SPACE
# Make zsh vi mode yank into system clipboard

source /Users/nikitavishenchiuk/code/bash_utils/entrypoint.sh

