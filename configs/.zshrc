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
# Make asdf work
. /opt/homebrew/opt/asdf/libexec/asdf.sh
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
alias configs='vim -c "call MakeRoot()" ${HOME}/dotfiles/configs/.zshrc'
alias tm='tmux'
alias cl='clear'
alias pgcli='PAGER=less pgcli'
alias tree="tree -C --dirsfirst"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
# This pipes output of z command (most commonly visited directories) to fzf
j() {
    [ $# -gt 0 ] && z "$*" && return
    cd "$(z -l 2>&1 | fzf --preview '' --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
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

#Below stop zsh-vi-mode conflicting with fzf bindings
function integrate_zsh_vi_mode_with_fzf() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  bindkey -s '^e' 'vim $(fzf)\n'
} 

zvm_after_init_commands+=(integrate_zsh_vi_mode_with_fzf)
source "$ZSH/oh-my-zsh.sh"
unsetopt hist_verify
# ASDF path config. Needs to be added after oh-my-zsh is sourced
# Make zsh vi mode yank into system clipboard
. $(brew --prefix asdf)/asdf.sh


source /Users/nikitavishenchiuk/code/bash_utils/entrypoint.sh

