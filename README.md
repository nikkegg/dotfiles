# Dotfiles
Dotfiles repo. Can be easily synced across your systems. Intended to be used on Mac OS.
Installs Homebrew, and whole bunch of utilities including oh-my-zsh, hub, git, fzf and more. Contains my terminal theme.

### One-line Install
```
bash -c "$(curl -#fL raw.github.com/nikkegg/dotfiles/main/install)"
```
All aliases point to dotfiles repo, to avoid accidentaly editing symlinks. Once install is complete, to initialise the repo, cd into root folder and do 

```
git init
git remote add origin git@github.com:nikkegg/dotfiles.git
git reset --hard origin/main
```

### TO-DO

Update coc-settings.json file for vim, to make coc install all needed extensions rather than doing this by hand
Add a script to install elixir language server, rather than doing it by hand


