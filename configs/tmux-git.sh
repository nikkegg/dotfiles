function git_status_to_regex {
	# run git status
	# appends | to each line
	# trims last |
	# Output looks like path/to/modified/file1|path/to/modified/file2 etc.
	local files=$(git status -s | cut -c4- | tr '\n' '|' | sed 's/.$//')
	# wraps into regex block
	local regex="($files)"
	echo $regex
}

function match_git_status {
  # enter copy-mode in tmux
	# backwards-search for all the files listed by git status
	tmux copy-mode;
	tmux send-keys -X search-backward "$git_status_to_regex";
	tmux send-keys 'n';
	exit 0
}


