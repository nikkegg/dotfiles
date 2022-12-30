function vim_test() {
current_pane_index=$(tmux list-panes -f '#{pane_active}' -F '#{pane_index}')
is_pane_zoomed=$(tmux list-panes -f '#{pane_active}' -F '#{window_zoomed_flag}')

# if pane is zoomed, we want to zoom out, because zoom affect list-panes command
if [ $is_pane_zoomed -eq 1 ]; then
  $(tmux resize-pane -Z)
fi

bottom_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_bottom}' -F '#{pane_index}')}")
top_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_top}' -F '#{pane_index}')}")
bottom_pane_count=${#bottom_pane_index_list[@]}
local test_command="$1"

# will create horizontal split if it doesnt exist
# exec zsh stops tmux pane from closing when process exists without
# setting global remain-on-exit tmux option
if [[ $bottom_pane_index_list == $top_pane_index_list ]]; then
  $(tmux splitw -dv "$test_command && exec zsh")
  return 0
fi

# use first existing horizontal split 
if [[ $bottom_pane_count -ge 1 ]]; then
  $(tmux send-keys -t bottom "$test_command" Enter)
  return 0
fi

return 0

}
