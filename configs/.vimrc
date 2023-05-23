""""""""""""""""""""""""
"  Plugins  "
""""""""""""""""""""""""
call plug#begin()
" Theme
  Plug 'dracula/vim', 
  " Normal vim motions with seeking
  Plug 'wellle/targets.vim'
  " View entire editing tree
  Plug 'mbbill/undotree'
  " Magic
  Plug 'vim-test/vim-test'
  " Filetree manager, git status for changes files, nerdtree icons
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/fern-git-status.vim'
  Plug 'lambdalisue/fern-mapping-quickfix.vim'
  " Error, warning and info summary in statusline
  Plug 'josa42/vim-lightline-coc'
  " Only show relative line number in active buffer
  Plug 'myusuf3/numbers.vim'
  " Search interface
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " LSP for vim
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " Modify * to also work with visual selections.
  Plug 'nelstrom/vim-visual-star-search'
  " Automatically clear search highlights after you move your cursor.
  Plug 'haya14busa/is.vim'
  Plug 'airblade/vim-gitgutter'
  Plug 'unblevable/quick-scope'
  Plug 'sheerun/vim-polyglot'
  Plug 'itchyny/lightline.vim'
  Plug 'tmux-plugins/vim-tmux'
  " Plug 'junegunn/goyo.vim'
  " Plug 'junegunn/limelight.vim'
  Plug 'christoomey/vim-system-copy'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'tpope/vim-commentary'
  Plug 'zivyangll/git-blame.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'tpope/vim-repeat'
  Plug 'ryanoasis/vim-devicons'
  " Text objects
  Plug 'kana/vim-textobj-user'
  Plug 'kana/vim-textobj-line'
  Plug 'kana/vim-textobj-indent'
  " Make qf list editable
  Plug 'romainl/vim-qf'
  " Preview for files in quickfix
  Plug 'ronakg/quickr-preview.vim'
  " Use vim as a pager. Supports link navigation via Enter/K. Tab S-Tab scrolls
  " man pages
  Plug 'lambdalisue/vim-pager'
  Plug 'lambdalisue/vim-manpager'
  Plug 'tpope/vim-surround'
  Plug 'antoinemadec/coc-fzf'
  Plug 'mhinz/vim-startify'
call plug#end()
"""""""""""""""""""""""
"  Plugin config, autocommands and commands  "
""""""""""""""""""""""""
"" Fern
""" Disable netrw
" :let g:loaded_netrw  = 1
:let g:loaded_netrwPlugin = 1
:let g:loaded_netrwSettings = 1
:let g:loaded_netrwFileHandlers = 1
" Pretty and git icons in file tree
let g:fern#renderer = "nerdfont"
""" Disable default Fern bindings
:let g:fern#disable_default_mappings = 1
:let g:fern#default_hidden = 1

augroup my-fern-hijack
  autocmd!
  autocmd BufEnter * ++nested call s:hijack_directory()
augroup END

""" Open tree on current file
function! s:hijack_directory() abort
  let path = expand('%:p')
  if !isdirectory(path)
    return
  endif
  bwipeout %
  execute printf('Fern %s', fnameescape(path))
endfunction

""" Fern init
function! FernInit() abort
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
  nmap <buffer> l <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> mk <Plug>(fern-action-new-path)
  nmap <buffer> d <Plug>(fern-action-remove)
  nmap <buffer> m <Plug>(fern-action-move)
  nmap <buffer> M <Plug>(fern-action-rename)
  nmap <buffer> h <Plug>(fern-action-hidden:toggle)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> t <Plug>(fern-action-mark:toggle)
  nmap <buffer> <C-t> <Plug>(fern-action-open:tabedit)
  nmap <buffer> <C-b> <Plug>(fern-action-open:split)
  nmap <buffer> <C-v> <Plug>(fern-action-open:vsplit)
  nmap <buffer> <C-q> <Plug>(fern-action-quickfix:new)
  nmap <buffer> <C-Q> <Plug>(fern-action-quickfix:add)
  nmap <buffer> y <Plug>(fern-action-yank)
  nmap <buffer> c <Plug>(fern-action-copy)
  nmap <buffer><nowait> < <Plug>(fern-action-leave)
  nmap <buffer><nowait> > <Plug>(fern-action-enter)
endfunction

augroup FernGroup
  autocmd!
  autocmd FileType fern setlocal norelativenumber | setlocal nonumber | set laststatus=0 | call FernInit()
  autocmd BufLeave * if &ft ==# 'fern' | set laststatus=2 | endif
augroup END
"" Vim-Commentary
augroup js_comment
  autocmd!
  autocmd FileType apache setlocal commentstring=#\ %s
  autocmd FileType elixir setlocal commentstring=#\ %s
  autocmd FileType javascript setlocal commentstring=\\\ %s
augroup END

"" FZF
""" Path
set rtp+=/usr/local/opt/fzf
""" FZF Selected buffer delete
function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))


function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-s': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

""" Options for default :FZF command
let g:fzf_files_options =
  \ '--preview="bat --color=always --style=numbers {}" --bind shift-up:preview-up,shift-down:preview-down,ctrl-S:select-all'


"" Coc-general
""" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  inoremap <silent><expr> <c-space> coc#refresh()
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:show_documentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

""" Highlight the symbol and its references when holding the cursor.
augroup CocSymbolHighlight
  autocmd!
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

""" Hover
nnoremap <silent> SD :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" function! ShowDocumentation()
"   if CocAction('hasProvider', 'hover')
"     call CocActionAsync('doHover')
"   else
"     call feedkeys('SD', 'in')
"   endif
" endfunction
nnoremap <silent><space>d :call CocAction('jumpDefinition', v:false)<CR>
""" Allows scrolling through pop-ups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
""" Stops coc.jsonc raising comment-related errors in json files
augroup format_json
  autocmd!
  autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc
augroup END
""" Custom path to coc-settings fulle
let g:coc_config_home = '$HOME/dotfiles/configs/'
""" List of CoC extensions
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-markdownlint', 'coc-tsserver', 'coc-yaml', 'coc-prettier', 'coc-eslint', 'coc-docker']
"" Status line
""" Displays numbers of errors and warnings as well as corresponding coc icongs in the statusline
let g:lightline#coc#indicator_hints = 'H '
let g:lightline#coc#indicator_info = 'I '
let g:lightline#coc#indicator_errors = 'E '
let g:lightline#coc#indicator_warnings = 'W '

function! LightlineLineinfo() abort
    if winwidth(0) < 60
        return ''
    endif

    let l:current_line = printf('%-3s', line('.'))
    let l:max_line = printf('%-3s', line('$'))
    let l:lineinfo = ' ' . l:current_line . '/' . l:max_line
    return l:lineinfo
endfunction

function! LightlineEncodinginfo() abort
    if winwidth(0) < 86
        return ''
    endif

    let l:encodinginfo = &fenc !=# '' ? &fenc : &enc
    return l:encodinginfo
endfunction
" Display branch symbol in statusline
function! FancyGitHead()
  return FugitiveHead() ." ".""
endfunction

" Add devicon to lightline
function! MyFileType()
  return winwidth(0) > 70 ? (WebDevIconsGetFileTypeSymbol(). " ". expand("%:t")) : ''
endfunction

let g:lightline = {
  \ 'colorscheme': 'seoul256',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste', 'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok'],
	\             [ 'readonly', 'filetype', 'modified' ]],
	\   'right': [ 
  \              [ 'mylineinfo'],
	\              [ 'gitbranch', 'encodinginfo'] ]
	\ },
  \ 'component_function': {
  \   'gitbranch': 'FancyGitHead',
  \   'filetype': 'MyFileType',
  \   'mylineinfo': 'LightlineLineinfo',
  \   'encodinginfo': 'LightlineEncodinginfo'
  \ },
  \ }
" Autcommand for lightline update
call lightline#coc#register()
"" Limelight
let g:limelight_default_coefficient = 0.8
"" Ripgrep
" Appending whitespace in funciton below enables Ripgrep work without search
" term
command! -bang -nargs=* Rg
      \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".(<q-args>).string(""), 1,
      \ fzf#vim#with_preview(), <bang>0)
"" Vim-fugitive
cnoreabbrev <expr> gst (getcmdtype() ==# ':' && getcmdline() ==# 'gst')  ? 'G' : 'gst'
cnoreabbrev <expr> gfp (getcmdtype() ==# ':' && getcmdline() ==# 'gfp')  ? 'G push --force-with-lease' : 'gfp'
cnoreabbrev <expr> gp (getcmdtype() ==# ':' && getcmdline() ==# 'gp')  ? 'G push' : 'gp'
cnoreabbrev <expr> gpull (getcmdtype() ==# ':' && getcmdline() ==# 'gpull')  ? 'G pull' : 'gpull'
cnoreabbrev <expr> grb (getcmdtype() ==# ':' && getcmdline() ==# 'grb')  ? 'G rebase -i origin/master' : 'grb'
cnoreabbrev <expr> ga (getcmdtype() ==# ':' && getcmdline() ==# 'ga')  ? 'G add --patch' : 'ga'
cnoreabbrev <expr> gc (getcmdtype() ==# ':' && getcmdline() ==# 'gc')  ? 'G commit' : 'ga'
cnoreabbrev <expr> stash (getcmdtype() ==# ':' && getcmdline() ==# 'stash')  ? 'G stash' : 'stash'
"" Number
let g:numbers_exclude = ['startify', 'vimshell', 'fern']
"" Quickscope
let g:qs_highlight_on_keys = ['t','T','f','F']
let g:qs_max_chars=150
augroup qs_colors
  autocmd!
  autocmd ColorScheme * highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
  autocmd ColorScheme * highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
augroup END
"" Vim-qf
" Allow Ack mapppings - v to vertical split,t to open in a tab, o to open and
" return, O to open and close quickfix list
let g:qf_mapping_ack_style = 0
let g:qf_auto_resize = 0
let g:qf_auto_quit = 0
let g:qf_shorten_path = 3

augroup QuickFix
  au!
  au FileType qf nnoremap <silent> <buffer> <C-b> <C-w><CR>
  au FileType qf nnoremap <silent> <expr> <buffer> <C-v> &splitright ? "\<C-w>\<CR>\<C-w>L\<C-w>p\<C-w>J\<C-w>p" : "\<C-w>\<CR>\<C-w>H\<C-w>p\<C-w>J\<C-w>p"
  au FileType qf nnoremap <silent> <buffer> <C-t> <C-w><CR><C-w>T
  nnoremap cc :call GoToEntry()<CR>
augroup END

"" Quickr-preview
" Allows to preview files in quickfix. Binding <leaderl>Space
let g:quickr_preview_on_cursor = 0 
" Close preview when quickfix is left
let g:quickr_preview_exit_on_enter = 1
"" Vim test
" Initialize runner command, which will be mutated whenever file in a package is opened
let g:workspace_test_runner = ''
let g:last_test_in_workspace = ''
" Initialize last test command, so that can use TestLast regardless of your
" location in monorepo
function! TmuxSplitNearestTestingStrategy(cmd)
  let l:test_command = g:workspace_test_runner." ".a:cmd
  let l:regex_and_path_split = split(split(l:test_command, ' -t ')[-1], '-- ')
  let l:test_regex = l:regex_and_path_split[0]
  let l:test_file_path = l:regex_and_path_split[1]
  let l:test_command = g:workspace_test_runner." ".l:test_file_path." -t ".l:test_regex
  let g:last_test_in_workspace = l:test_command
  call system("source $HOME/vim-test.sh && vim_test ".shellescape(l:test_command))
endfunction

function! TmuxSplitFileTestingStrategy(cmd)
  let l:test_command = g:workspace_test_runner." ".a:cmd
  let l:test_file_path = split(l:test_command, '-- ')[-1]
  let l:test_command = g:workspace_test_runner." ".l:test_file_path
  let g:last_test_in_workspace = l:test_command
  call system("source $HOME/vim-test.sh && vim_test ".shellescape(l:test_command))
endfunction

function! TmuxSplitSuiteTestingStrategy(cmd)
  let l:test_command = g:workspace_test_runner." ".a:cmd
  let g:last_test_in_workspace = l:test_command
  call system("source $HOME/vim-test.sh && vim_test ".shellescape(l:test_command))
endfunction

function! TmuxSplitLastTestingStrategy()
  call system("source $HOME/vim-test.sh && vim_test ".shellescape(g:last_test_in_workspace))
endfunction

function! MonorepoTestLast()
  call system("source $HOME/vim-test.sh && vim_test ".shellescape(g:last_test_command))
endfunction

let g:test#custom_strategies = {'tmux_vertical_split_nearest': function('TmuxSplitNearestTestingStrategy'), 'tmux_vertical_split_file': function('TmuxSplitFileTestingStrategy'), 'tmux_vertical_split_suite': function('TmuxSplitSuiteTestingStrategy'), 'tmux_vertical_split_last': function('TmuxSplitLastTestingStrategy')}
let g:test#echo_command = 0
let test#strategy = {
  \ 'nearest': 'tmux_vertical_split_nearest',
  \ 'file':    'tmux_vertical_split_file',
  \ 'suite':   'tmux_vertical_split_suite'
\}
" Tells vim test to use script defined in package.json
let g:test#javascript#jest#executable = ''
let g:test#runner_commands = ['Jest']
let g:test#javascript#runner = 'jest'
" Only load jest
let g:test#enabled_runners =  ["javascript#jest"]
" This is a bit annoying, but is required to make vim-test work with monorepos. It will change test command based on test file in focus to yarn wortkspace @sylvera/<workspace>. This is then used by vim-test.sh to run test in horizontal tmux splits
augroup MonorepoPathsVimTest
  autocmd!
  autocmd BufEnter ~/code/public-api/packages/monitoring/* let g:workspace_test_runner = "yarn workspace @sylvera/monitoring"
  autocmd BufEnter ~/code/public-api/packages/auth/* let g:workspace_test_runner = "yarn workspace @sylvera/auth test"
  autocmd BufEnter ~/code/public-api/packages/cache-projects/* let g:workspace_test_runner = "yarn workspace @sylvera/cache-projects test"
  autocmd BufEnter ~/code/public-api/packages/cognito/* let g:workspace_test_runner = "yarn workspace @sylvera/cognito test"
  autocmd BufEnter ~/code/public-api/packages/container/* let g:workspace_test_runner = "yarn workspace @sylvera/container test"
  autocmd BufEnter ~/code/public-api/packages/database-projects/* let g:workspace_test_runner = "yarn workspace @sylvera/database-projects test"
  autocmd BufEnter ~/code/public-api/packages/emails/* let g:workspace_test_runner = "yarn workspace @sylvera/emails test"
  autocmd BufEnter ~/code/public-api/packages/maps/* let g:workspace_test_runner = "yarn workspace @sylvera/maps test"
  autocmd BufEnter ~/code/public-api/packages/notifications/* let g:workspace_test_runner = "yarn workspace @sylvera/notifications test"
  autocmd BufEnter ~/code/public-api/packages/projects/* let g:workspace_test_runner = "yarn workspace @sylvera/projects test"
  autocmd BufEnter ~/code/public-api/packages/shared/* let g:workspace_test_runner = "yarn workspace @sylvera/shared test"
  autocmd BufEnter ~/code/public-api/packages/usage/* let g:workspace_test_runner = "yarn workspace @sylvera/usage test"
  autocmd BufEnter ~/code/public-api/packages/users/* let g:workspace_test_runner = "yarn workspace @sylvera/users test"
  autocmd BufEnter ~/code/public-api/packages/versions-service/* let g:workspace_test_runner = "yarn workspace @sylvera/versions-service test"
  autocmd BufEnter ~/code/public-api/packages/integration-tests/* let g:workspace_test_runner = "yarn workspace @sylvera/integration-tests test"
  autocmd BufEnter ~/code/public-api/packages/s3-cache/* let g:workspace_test_runner = "yarn workspace @sylvera/s3-cache test"
  autocmd BufEnter ~/code/public-api/packages/feature-flags/* let g:workspace_test_runner = "yarn workspace @sylvera/feature-flags test"
  autocmd BufEnter ~/code/public-api/packages/api-retirements/* let g:workspace_test_runner = "yarn workspace @sylvera/api-retirements test"

  autocmd BufEnter ~/code/sylvera-service-lambdas/apps/service-database-etl/* let g:workspace_test_runner = "yarn workspace @apps/service-database-etl test"
  autocmd BufEnter ~/code/sylvera-service-lambdas/apps/pdf-generation/* let g:workspace_test_runner = "yarn workspace @apps/pdf-generation test"
  autocmd BufEnter ~/code/sylvera-service-lambdas/apps/post-authentication/* let g:workspace_test_runner = "yarn workspace @apps/post-authentication test"
  autocmd BufEnter ~/code/sylvera-service-lambdas/apps/post-auth-event-processing/* let g:workspace_test_runner = "yarn workspace @apps/post-auth-event-processing test"
augroup END

"" Gitgutter
let g:gitgutter_preview_win_floating = 0
let g:gitgutter_map_keys = 0
let g:gitgutter_set_sign_backgrounds = 1
let g:gitgutter_sign_added = '|'
let g:gitgutter_sign_modified = '|'
let g:gitgutter_sign_removed = '|'
let g:gitgutter_sign_removed_first_line = '|'
let g:gitgutter_sign_removed_above_and_below = '|'
let g:gitgutter_sign_modified_removed = '|'
let g:gitgutter_enabled = 1
"" Filtetype autocommands
augroup Filtetypes
  autocmd!
au BufNewFile,BufRead *.ejs set filetype=html
augroup END
"" Vim polyglot
" Conceal quotes in json files
let g:vim_json_syntax_conceal = 1
"" Startify
" :SLoad    load a session
" :SSave    save a session
" :SDelete  delete a session
" :SClose   close current session
" Dont automgically change dir when opening MRUs
let g:startify_change_to_dir = 0
" 'Most Recent Files' number
let g:startify_files_number           = 8

" Update session automatically as you exit vim
let g:startify_session_persistence    = 1

" Simplify the startify list to just recent files and sessions
let g:startify_lists = [
  \ { 'type': 'dir',       'header': ['   Recent files'] },
  \ { 'type': 'sessions',  'header': ['   Saved sessions'] },
  \ ]

" Fancy custom header
let g:startify_custom_header = [
  \ "  ",
  \ '   ╻ ╻   ╻   ┏┳┓',
  \ '   ┃┏┛   ┃   ┃┃┃',
  \ '   ┗┛    ╹   ╹ ╹',
  \ '   ',
  \ ]
"""""""""""""""""""""""
"  General settings  "
""""""""""""""""""""""""
" For git gutter
set signcolumn=yes
set nocompatible
set encoding=utf-8
set autoindent
set hidden
set nobackup
set noshowcmd
set nowritebackup
set noswapfile
set updatetime=300
set shortmess+=c
syntax on
" Colorscheme and cursor
" let g:seoul256_background = 233
set background=dark
" colorscheme seoul256
colorscheme dracula
hi Normal guibg=NONE ctermbg=NONE
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set autoread
set backspace=indent,eol,start
set cursorline
set hlsearch
set ignorecase
set incsearch
set noerrorbells visualbell t_vb=
set number relativenumber
set laststatus=2
set wrap " turn on line wrapping
set linebreak " set soft wrapping
set showbreak=… " show ellipsis at breaking
set scrolloff=5
set textwidth=80
" Folding
set foldmethod=syntax
set foldlevel=99
" Disable statusline (embed in tmux status bar instead)
" set noshowmode
" set noruler
" set laststatus=0
" set noshowcmd
" set nomore
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let &t_TI = ""
let &t_TE = ""
set wildmenu
set wildmode=longest,full

" Vim in tmux specific conf
set ttymouse=sgr

" Enable true colors, see  :help xterm-true-color
let &termguicolors = v:true
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Enable bracketed paste mode, see  :help xterm-bracketed-paste
let &t_BE = "\<Esc>[?2004h"
let &t_BD = "\<Esc>[?2004l"
let &t_PS = "\<Esc>[200~"
let &t_PE = "\<Esc>[201~"

" Enable focus event tracking, see  :help xterm-focus-event
let &t_fe = "\<Esc>[?1004h"
let &t_fd = "\<Esc>[?1004l"
execute "set <FocusGained>=\<Esc>[I"
execute "set <FocusLost>=\<Esc>[O"

" Enable modified arrow keys, see  :help arrow_modifiers
execute "silent! set <xUp>=\<Esc>[@;*A"
execute "silent! set <xDown>=\<Esc>[@;*B"
execute "silent! set <xRight>=\<Esc>[@;*C"
execute "silent! set <xLeft>=\<Esc>[@;*D"

"" Vim plugins
runtime! ftplugin/man.vim
packadd cfilter
" Fold verything if opening .vimrc
augroup FoldVimrc
  autocmd!
  autocmd BufEnter .vimrc setl foldlevel=0
augroup END

""""""""""""""""""""""""
"  Bindings  "
""""""""""""""""""""""""
"" Gitgutter bindings
" Hunk text object
" omap ih <Plug>(GitGutterTextObjectInnerPending)
" omap ah <Plug>(GitGutterTextObjectOuterPending)
" xmap ih <Plug>(GitGutterTextObjectInnerVisual)
" xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nnoremap [h :call GitGutterNextHunkCycle()<CR> 
nnoremap ]h <Plug>(GitGutterPrevHunk)
nnoremap gph <Plug>(GitGutterPreviewHunk)
nnoremap <Leader>hs <Plug>(GitGutterStageHunk)
nnoremap <Leader>hu <Plug>(GitGutterUndoHunk)
function! GitGutterNextHunkCycle()
  let line = line('.')
  silent! GitGutterNextHunk
  if line('.') == line
    1
    GitGutterNextHunk
  endif
endfunction
"" Leader key bindings
:let mapleader = ","
" Echo current file
:nnoremap <leader>e :echo @%<CR>
" Find and replace in a single file
:nnoremap <leader>r :%s/<c-r>=expand("<cword>")<cr>//g<Left><Left>
" Does the same as the above but works on visually selected text
:xnoremap <leader>r y<Esc>:%s/<C-R>"//g<Left><Left>
" Find in replace in multiple files - work in progress
:nnoremap <leader>R :Grep <c-r>=expand("<cword>")<cr><cr><cr>:cfdo %s/<c-r>=expand("<cword>")<cr>//ge \| cclose \| wa!<C-Left><C-Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
" Toggle quickfix
:nnoremap <silent> <leader>cc :call ToggleQuickfixOrLocationLists()<CR>
:nnoremap <leader>d dd
:nnoremap <leader>ev :vsplit ~/dotfiles/configs/.vimrc<cr>
:nnoremap <leader>sv :source ~/.vimrc<cr>
:inoremap <leader>' <esc>viw<esc>a"<esc>bi"<esc>leli<Right><Space>
"Opens Fern filetree
:nnoremap <silent> <Leader>f :Fern . -drawer -reveal=% -toggle -width=35<CR><C-w>=
" Switch between tabs
:nnoremap <leader>. :tabprevious<CR>
:nnoremap <leader>/ :tabnext<CR>
" Limelight
nnoremap <silent><leader>l :Limelight!!<CR>
" Echo git blame
nnoremap <Leader>gb :<C-u>call gitblame#echo()<CR>
" Write and quit with leader
nnoremap <leader>w :w!<cr>
nnoremap <leader>q :q!<CR>
" Vim test
nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>
nnoremap <leader>ts :TestSuite<CR>
nnoremap <leader>tl :call TmuxSplitLastTestingStrategy()<CR>
nnoremap <leader>tv :TestVisit<CR>
" Copy current buffer's path
:nmap <silent> <leader>cpa :let @+ = expand("%")<CR>

"" Move lines up and down like in VScode
nnoremap K :m .-2<CR>==
nnoremap J :m .+1<CR>==
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

"" Multiple cursors
" Type a replacement term and press . to repeat the replacement again. Useful
" for replacing a few instances of the term (comparable to multiple cursors).
nnoremap <silent> s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent> s* "sy:let @/=@s<CR>cgn
"" Rebinds
:inoremap jk <esc>
:nnoremap <CR> o<esc>
:nnoremap <S-CR> O<esc>
:nnoremap <silent> j gj
:nnoremap <silent> k gk
:nnoremap <silent> 0 g0
:nnoremap <silent> $ g$
:nnoremap <silent> 0 ^
:nnoremap <silent> ^ 0
"" Split management
" This mappings allow to move through vertical splits and tmux splits
let g:tmux_navigator_no_mappings = 1
:nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
:nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
:nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
:nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
:nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>
:nnoremap <silent> <C-v> :vsplit<cr>
" Split resize
:nnoremap <silent> <Right> :vertical resize +5<cr>
:nnoremap <silent> <Left> :vertical resize -5<cr>
:nnoremap <silent> <Up> :resize -5<cr>
:nnoremap <silent> <Down> :resize +5<cr>

"" Vim terminal bindings
:tnoremap <C-q> <C-w><C-c>
:nnoremap top :vert terminal<CR>
"" Search bindings
:nnoremap <space>p :Files<CR>
:nnoremap <space>h :History<CR>
:nnoremap <space>f :Rg<space>
:nnoremap <space>r :Rg <C-r><C-w><CR>
"" CoC bindings
:nnoremap <silent> gd <Plug>(coc-definition)
:nnoremap <silent> gdv :call CocAction('jumpDefinition', 'vsplit')<cr>
:nnoremap <silent> gdt :call CocAction('jumpDefinition', 'tabe')<cr>
" Super useful - takes you to return type when called on a function
:nnoremap <silent> gy :let g:quickr_preview_on_cursor = 1<CR> <Plug>(coc-type-definition)
nmap <leader>ac <Plug>(coc-codeaction)
" Places where the target is being used
:nnoremap <silent> gr :let g:quickr_preview_on_cursor = 1<CR> <Plug>(coc-references)
" Less useful - rather than definition, it takes you to a file where export
" occured
:nnoremap <silent> gi <Plug>(coc-implementation)
:nnoremap <silent> ]d <Plug>(coc-diagnostic-prev)
:nnoremap <silent> [d <Plug>(coc-diagnostic-next)
nmap <leader>rn <Plug>(coc-rename)
command! D :CocDiagnostics<CR>
"" Scroll the viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
" Undotree
command! UT :UndotreeToggle
""""""""""""""""""""""""
" Plugin-unrelated functions  "
""""""""""""""""""""""""
"" Make current dir root
" Use with configs alias in zshrc
function! MakeRoot()
  :cd %:p:h
  :setl foldlevel=0
endfunction
"" Zoom in on vim split
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=
"" File template mapppings
noremap ,docker :. ! curl -s https://raw.githubusercontent.com/nikkegg/notes/main/docker/Dockerfile<CR>
noremap ,dockerc :. ! curl -s https://raw.githubusercontent.com/nikkegg/notes/main/docker/docker-compose.yaml<CR>
""""""""""""""""""""""""
"  Abbreviations  "
""""""""""""""""""""""""
"" Typescript
augroup typescript_abbr
  autocmd!
  autocmd BufRead,BufNewFile *.ts,*.spec.ts call TypescriptAbbrev()
augroup END

function! TypescriptAbbrev()
  :iabbrev ca const=;<Left><Left>
  :iabbrev la let=;<Left><Left>
  :iabbrev ima import {} from '';<Left><Left>
  :iabbrev cla console.log()<Left>
  :iabbrev ifa if() {<CR>}<Esc>%i<Left><Left>
  :iabbrev fua function() {<CR>}<Esc>%F(i
  :iabbrev afua async function() {<CR>}<Esc>%F(i
endfunction

""""""""""""""""""""""""
"  Custom functions  "
""""""""""""""""""""""""
"" Toggle quickfix and location list with the same binding
" I rarely user location list, mostly by running 3rd party commands like
" CocDiagnostics which populates location list. This why function below only
" closes location list, but toggle quickfix list which I use more frequently
function! ToggleQuickfixOrLocationLists()
  let quickfix_list_closed = empty(filter(getwininfo(), 'v:val.quickfix'))
  let location_list_closed = empty(filter(getwininfo(), 'v:val.loclist'))
  if quickfix_list_closed
    copen
  elseif !quickfix_list_closed || !location_list_closed
    if !quickfix_list_closed
      let g:quickr_preview_on_cursor = 0
      cclose | pclose
    end
    if !location_list_closed 
      let g:quickr_preview_on_cursor = 0
      lclose | pclose
    end
  end
endfunction

"" Make cc work on line under the cursor in quickfix and location lists
function! GoToEntry()
  let quickfix_list_open = !empty(filter(getwininfo(), 'v:val.quickfix'))
let loclist_open = !empty(filter(getwininfo(), 'v:val.loclist'))

  if loclist_open
    :.ll | pclose
  elseif quickfix_list_open
    :.cc | pclose
  else 
    echo "No active loc or quickfix list"
  end
endfunction
""""""""""""""""""""""""
"  Custom folding  "
""""""""""""""""""""""""
" Bindings
" use standard vim fold bindings
" see http://vimcasts.org/episodes/writing-a-custom-fold-expression/
" see http://vimcasts.org/episodes/writing-a-custom-fold-expression/
"" defines a foldlevel for each line of code
function! VimFolds(lnum)
  let s:thisline = getline(a:lnum)
  if match(s:thisline, '^"" ') >= 0
    return '>2'
  endif
  if match(s:thisline, '^""" ') >= 0
    return '>3'
  endif
  let s:two_following_lines = 0
  if line(a:lnum) + 2 <= line('$')
    let s:line_1_after = getline(a:lnum+1)
    let s:line_2_after = getline(a:lnum+2)
    let s:two_following_lines = 1
  endif
  if !s:two_following_lines
      return '='
    endif
  else
    if (match(s:thisline, '^"""""') >= 0) &&
       \ (match(s:line_1_after, '^"  ') >= 0) &&
       \ (match(s:line_2_after, '^""""') >= 0)
      return '>1'
    else
      return '='
    endif
  endif
endfunction

"" defines a foldtext
function! VimFoldText()
  " handle special case of normal comment first
  let s:info = '('.string(v:foldend-v:foldstart).' l)'
  if v:foldlevel == 1
    let s:line = ' ◇ '.getline(v:foldstart+1)[3:-2]
  elseif v:foldlevel == 2
    let s:line = '   ●  '.getline(v:foldstart)[3:]
  elseif v:foldlevel == 3
    let s:line = '     ▪ '.getline(v:foldstart)[4:]
  endif
  if strwidth(s:line) > 80 - len(s:info) - 3
    return s:line[:79-len(s:info)-3+len(s:line)-strwidth(s:line)].'...'.s:info
  else
    return s:line.repeat(' ', 80 - strwidth(s:line) - len(s:info)).s:info
  endif
endfunction

"" set foldsettings automatically for vim files
augroup fold_vimrc
  autocmd!
  autocmd FileType vim
                   \ setlocal foldmethod=expr |
                   \ setlocal foldexpr=VimFolds(v:lnum) |
                   \ setlocal foldtext=VimFoldText() |
     "              \ set foldcolumn=2 foldminlines=2
augroup END

""""""""""""""""""""""""
"   WIP   "
""""""""""""""""""""""""
"" text object indent
" omap ia <Plug>(textobj-indent-a)
" omap  <Plug>(GitGutterTextObjectOuterPending)
" xmap ih <Plug>(GitGutterTextObjectInnerVisual)
" xmap ah <Plug>(GitGutterTextObjectOuterVisual)

"" Ripgrep
"Attempt to make ripgrep respect usual flags, but also to support regex in-built regex engine
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
"" My attempt
" Idea is to be able to parse rg with positional arguments and flags,
" whilst still using regex
" Example: rg -w '^function' file.ext
"branching:
  " if 1 arg, assume simple query
  " if two args and one is a path, assume simple query with a path
  " if two or more args and no path, assume query and a flag
  " if
" TO-DO:
" fix preview when passing an in argument
" support flags and in argument when realoading the query
function! BuildRgCommand(arg_count, arg_list)
  if a:arg_count >= 2 && a:arg_list[-1] =~ 'in=*'
    let dir_param = split(a:arg_list[-1], '=')[1]
    let query = a:arg_list[-2]
    let ripgrep_flags = join(a:arg_list[0:-3], " ")
    let base_command =$VIM_RG.' '.ripgrep_flags.' %s '.dir_param
    return printf(base_command, shellescape(query))
  else 
    let query = a:arg_list[-1]
    let ripgrep_flags = join(a:arg_list[0:-2], " ")
    let base_command =$VIM_RG.' '.ripgrep_flags.' %s '
    return printf(base_command, shellescape(query))
 endif
endfunction

function! RipTest(args, fullscreen)
  let arg_list = split(a:args, " ")
  let arg_count = len(arg_list)
  if arg_count == 0
    call RipgrepFzf('', a:fullscreen)
  elseif arg_count == 1
    call RipgrepFzf(arg_list[0], a:fullscreen)
  else
    let initial_command = BuildRgCommand(arg_count, arg_list)
    let spec = {'options': ['--phony']}
   call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
 endif
endfunction

command! -nargs=* -bang RT call RipTest(<q-args>, <bang>0)

