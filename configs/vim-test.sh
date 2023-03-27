function vim_test() {
  current_pane_index=$(tmux list-panes -f '#{pane_active}' -F '#{pane_index}')
  is_pane_zoomed=$(tmux list-panes -f '#{pane_active}' -F '#{window_zoomed_flag}')

  # if pane is zoomed, we want to zoom out, because zoom affects list-panes command
  if [ $is_pane_zoomed -eq 1 ]; then
    $(tmux resize-pane -Z)
  fi

  bottom_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_bottom}' -F '#{pane_index}')}")
  top_pane_index_list=("${(@f)$(tmux list-panes -f '#{pane_at_top}' -F '#{pane_index}')}")
  bottom_pane_count=${#bottom_pane_index_list[@]}
  first_bottom_pane_index=${bottom_pane_index_list[@]:0:1}
  currently_running_process=$(tmux display -p -t bottom '#{pane_current_command}')
  local test_command="$1"

  # process. This avoids sending test command to splits running vim/other
  # use first existing horizontal split if it exists and is running a shell
  # long-running processes
  if [[ $bottom_pane_count -ge 1 && $currently_running_process =~ (zsh|bash|fish) ]]; then
    $(tmux send-keys -t bottom "$test_command" Enter)
    return 0
  fi

  # else create new horizontal split
  # exec zsh stops tmux pane from closing when process exists.
  # This helps to avoid setting global remain-on-exit tmux option
  $(tmux splitw -dv "($test_command || exit 0) && zsh")
  return 0
}
