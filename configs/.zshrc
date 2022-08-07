# zsh
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="obraun"
ZSH_DISABLE_COMPFIX=true
HIST_STAMPS="dd.mm.yyyy"
COMPLETION_WAITING_DOTS="true"
ZVM_VI_ESCAPE_BINDKEY=jk
EDITOR='vim'
MOST_EDITOR='vim'
# Exports
export ZSH="${HOME}/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER='most'
# Homebrew
# Make homebrew work on Apple Silicone
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ANALYTICS=1
# Plugins
plugins=(z zsh-vi-mode gitfast common-aliases zsh-syntax-highlighting)

# Aliases
alias vim="vim -S ~/.vimrc"
alias gst='git status'
alias gc='git commit'
alias gco='git checkout'
alias ga='git add -p'
alias ..='cd ..'
alias gfp='git push --force-with-lease'
alias git='hub'
# alias fhub='GITHUB_TOKEN=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 hub'
alias configs='vim -c "call MakeRoot()" ${HOME}/dotfiles/configs/.zshrc'
alias tm='tmux'
# FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!{.git,.svn,.hg,node_modules,.dump,.sql,.cjs.js,cjs.js.map,.esm.js,.esm.js.map}'"
# export FZF_DEFAULT_OPTS="--preview='bat --color=always --style=numbers {}' --bind shift-up:preview-up,shift-down:preview-down"
export FZF_CTRL_R_OPTS="--preview=''"
export FZF_ALT_C_OPTS="--preview='tree -C {} | head -200'"

# This pipes output of z command (most commonly visited directories to fzf
j() {
    [ $# -gt 0 ] && z "$*" && return
    cd "$(z -l 2>&1 | fzf --preview '' --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
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
# ASDF path config. Needs to be added after oh-my-zsh is sourced
. $(brew --prefix asdf)/asdf.sh
