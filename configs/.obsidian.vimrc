""""""""""""""""""""""
" Leader
""""""""""""""""""""""
" let mapleader=,
" can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior: https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
unmap ,
unmap <Space>

imap jk <Esc>
nmap <CR> o<Esc>
nmap <S-CR> O<Esc>

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk
nmap 0 g0
nmap $ g$
nmap 0 ^
nmap ^ 0


" Yank to system clipboard
set clipboard=unnamed

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back
exmap forward obcommand app:go-forward
nmap <C-i> :forward

" vim-surround imitation
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }

" NOTE: must use 'map' and not 'nmap'
map [[ :surround_wiki
nunmap s
vunmap s
map s" :surround_double_quotes
map s' :surround_single_quotes
map s` :surround_backticks
map sb :surround_brackets
map s( :surround_brackets
map s) :surround_brackets
map s[ :surround_square_brackets
map s[ :surround_square_brackets
map s{ :surround_curly_brackets
map s} :surround_curly_brackets

" Emulate Folding https://vimhelp.org/fold.txt.html#fold-commands
exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold
nmap zc :togglefold
nmap za :togglefold

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall

exmap foldall obcommand editor:fold-all
nmap zM :foldall

" Pastes text from clipboard inside vissually selected text. Useful for pasting
" into link delimiters
" map <C-p> :pasteinto

" requires Pane Relief: https://github.com/pjeby/pane-relief
exmap tabnext obcommand workspace:next-tab
nmap ,/ :tabnext
exmap tabprev obcommand workspace:previous-tab
nmap ,. :tabprev

"" Move lines up and down like in VScode
exmap linedown obcommand editor:swap-line-down
exmap lineup obcommand editor:swap-line-up
nmap K :lineup
nmap J :linedown
" These do no work
" vmap K :lineup
" vmap J :linedown

" window controls
exmap wq obcommand workspace:close
exmap q obcommand workspace:close
exmap wa obcommand editor:save-file
exmap fern obcommand app:toggle-left-sidebar
nmap ,q :q
nmap ,w :wa
nmap ,f :fern


" focus
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusBottom obcommand editor:focus-bottom
exmap focusTop obcommand editor:focus-top
nmap <C-h> :focusLeft
nmap <C-l> :focusRight
nmap <C-j> :focusBottom
nmap <C-k> :focusTop

" mapping vs/hs as workspace split
exmap vs obcommand workspace:split-vertical
exmap hs obcommand workspace:split-horizontal
exmap newtab obcommand workspace:new-tab
nmap <C-v> :vs
nmap <C-b> :hs
nmap <C-t> :newtab

" search
"" files
exmap switcher obcommand switcher:open
nmap <Space>p :switcher
exmap search obcommand global-search:open
nmap <Space>r :search
"" file content

" go-to
"" open in the new tab
exmap openlink obcommand editor:open-link-in-new-leaf
nmap gt :openlink

"" open in the vertical split
exmap openlinkvertical obcommand editor:open-link-in-new-split
nmap gv :openlinkvertical


"" open in the same pane
exmap followLinkUnderCursor obcommand editor:follow-link
nmap gd :followLinkUnderCursor

" jump to next heading
exmap nextHeading jsfile mdHelpers.js {jumpHeading(true)}
exmap prevHeading jsfile mdHelpers.js {jumpHeading(false)}
nmap ]] :nextHeading
nmap [[ :prevHeading

