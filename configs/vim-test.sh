function vim_test() {
current_pane_index=$(tmux list-panes -f '#{pane_active}' -F '#{pane_index}')
is_pane_zoomed=$(tmux list-panes -f '#{pane_active}' -F '#{window_zoomed_flag}')
bottom_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_bottom}' -F '#{pane_index}')}")
top_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_top}' -F '#{pane_index}')}")
bottom_pane_count=${#bottom_pane_index_list[@]}
local test_command="$1"

# will create horizontal split
# exec zsh stops tmux pane from closing when process exists without
# setting global remain-on-exit tmux option
if [[ $bottom_pane_index_list == $top_pane_index_list && $is_pane_zoomed -ne 1 ]]; then
  $(tmux splitw -dv "$test_command && exec zsh")
  return 0
fi

# use first existing horizontal split 
if [[ $bottom_pane_count -ge 1 && $is_pane_zoomed -ne 1 ]]; then
  $(tmux send-keys -t bottom "$test_command" Enter)
  return 0
fi

if [ $is_pane_zoomed -eq 1 ]; then
  $(tmux resize-pane -Z)
  bottom_pane_index_list_zoomed=("${(@f)$(tmux list-panes -f '#{pane_at_bottom}' -F '#{pane_index}')}")
  top_pane_index_list_zoomed=("${(@f)$(tmux list-panes -f '#{pane_at_top}' -F '#{pane_index}')}")
  bottom_pane_count_zoomed=${#bottom_pane_index_list[@]}

  if [[ $bottom_pane_index_list_zoomed == $top_pane_index_list_zoomed ]]; then
    $(tmux splitw -dv "$test_command && exec zsh")
    return 0
  fi

  if [[ $bottom_pane_count_zoomed -ge 1 ]]; then
    $(tmux send-keys -t bottom "$test_command" Enter)
    return 0
  fi
fi

return 0

}

