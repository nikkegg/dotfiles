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
export ZSH="~/.oh-my-zsh"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HOMEBREW_NO_ANALYTICS=1
export PAGER='most'
# Plugins
plugins=(zsh-vi-mode gitfast last-working-dir common-aliases)

# ASDF path config
. $(brew --prefix asdf)/asdf.sh

# Sources
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/oh-my-zsh.sh
# Aliases
unalias rm
alias vim="vim -S ~/.vimrc"
alias gst='git status'
alias gc='git commit'
alias gco='git checkout'
alias ga='git add -p'
alias ..='cd ..'
alias gfp='git push --force-with-lease'
alias fhub='GITHUB_TOKEN=TOEN hub'
alias zshrc='vim /usr/local/opt/dotfiles/configs/.zshrc'
alias tm='tmux'
# FZF
alias fzf="fzf --preview='bat --color=always --style=numbers {}' --bind shift-up:preview-up,shift-down:preview-down"
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!{.git,.svn,.hg,node_modules,.dump,.sql,.cjs.js,cjs.js.map,.esm.js,.esm.js.map}'"

weather () {
    curl "https://wttr.in/${1}"
}

#Editor
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | pbcopy
}

. /usr/local/opt/asdf/libexec/asdf.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#Below stop zsh-vi-mode conflicting with fzf bindings
function integrate_zsh_vi_mode_with_fzf() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  bindkey -s '^e' 'vim $(fzf)\n'
} 
zvm_after_init_commands+=(integrate_zsh_vi_mode_with_fzf)
