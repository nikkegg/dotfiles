function vim_test() {
current_pane_index=$(tmux list-panes -f '#{pane_active}' -F '#{pane_index}')
bottom_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_bottom}' -F '#{pane_index}')}")
top_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_top}' -F '#{pane_index}')}")
bottom_pane_count=${#bottom_pane_index_list[@]}
first_bottom_pane_index=${bottom_pane_index_list[@]:0:1}
local test_command="$1"

# will create horizontal split
# exec zsh stops tmux pane from closing when process exists without
# setting global remain-on-exit tmux option
if [[ $bottom_pane_index_list == $top_pane_index_list ]]; then
  $(tmux splitw -dv "$test_command && exec zsh")
  return 0
fi

# use first existing horizontal split 
if [[ $bottom_pane_count -ge 1 ]]; then
  $(tmux send-keys -t $first_bottom_pane_index "$test_command" Enter)
  return 0
fi
}

