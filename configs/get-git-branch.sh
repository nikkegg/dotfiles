PANE_CURRENT_PATH="$1"

function copy_branch { 
 git -C "$PANE_CURRENT_PATH" rev-parse --abbrev-ref HEAD | tr -d '\n' | pbcopy
}

copy_branch
