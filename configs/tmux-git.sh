PANE_CURRENT_PATH="$1"

# Match output of git status to facilitate a quick jump to it in tmux
function match_git_status {
	# below creates a regex pattern from output of git status in the from
	# (git_status_file1|git_status_file2|...)
	local files="($(git -C "$PANE_CURRENT_PATH" status -s | cut -c4- | tr '\n' '|' | sed 's/.$//'))"
	tmux copy-mode;
	tmux send-keys -X search-backward "$files";
}

match_git_status
