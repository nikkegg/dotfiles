""""""""""""""""""""""""
"  Plugins  "
""""""""""""""""""""""""
call plug#begin()
" Run asyn jobs from inside vim 😍
  Plug 'skywind3000/asyncrun.vim'
  " Theme
  Plug 'junegunn/seoul256.vim'
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
  Plug 'unblevable/quick-scope'
  Plug 'sheerun/vim-polyglot'
  Plug 'itchyny/lightline.vim'
  Plug 'tmux-plugins/vim-tmux'
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/limelight.vim'
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
  "Embedd vim statusline in tmux status bar
  Plug 'vimpostor/vim-tpipeline'
  " Use vim as a pager
  Plug 'lambdalisue/vim-pager'
  Plug 'lambdalisue/vim-manpager'
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
  nmap <buffer> T <Plug>(fern-action-open:tabedit)
  nmap <buffer> b <Plug>(fern-action-open:split)
  nmap <buffer> v <Plug>(fern-action-open:vsplit)
  nmap <buffer> y <Plug>(fern-action-yank)
  nmap <buffer> c <Plug>(fern-action-copy)
  nmap <buffer><nowait> < <Plug>(fern-action-leave)
  nmap <buffer><nowait> > <Plug>(fern-action-enter)
endfunction

augroup FernGroup
  autocmd!
  autocmd FileType fern setlocal norelativenumber | setlocal nonumber | call FernInit()
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

""" Options for default :FZF command
let g:fzf_files_options =
  \ '--preview="bat --color=always --style=numbers {}" --bind shift-up:preview-up,shift-down:preview-down'


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
nnoremap <silent> SD :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('SD', 'in')
  endif
endfunction
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
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-css', 'coc-elixir', 'coc-html', 'coc-markdownlint', 'coc-tsserver', 'coc-yaml', 'coc-prettier', 'coc-eslint']
"" Status line
""" Displays numbers of errors and warnings as well as corresponding coc icongs in the statusline
let g:lightline#coc#indicator_hints = 'H '
let g:lightline#coc#indicator_info = 'I ' 
let g:lightline#coc#indicator_errors = 'E '
let g:lightline#coc#indicator_warnings = 'W '
let g:lightline = {
  \ 'colorscheme': 'seoul256',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste', 'coc_info', 'coc_hints', 'coc_errors', 'coc_warnings', 'coc_ok'],
	\             [ 'readonly', 'filetype', 'modified' ]],
	\   'right': [ [ 'percent' ],
	\              ['teststatus', 'gitbranch', 'fileencoding'] ]
	\ },
  \ 'component_function': {
  \   'gitbranch': 'FancyGitHead',
  \   'filetype': 'MyFileType',
  \   'teststatus': 'TestStatus'
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
let g:qf_mapping_ack_style = 1
"" Vim test
let g:test#echo_command = 0
" Run tests async, to view results open quickfix window
let g:test#strategy = 'asyncrun_background'
" Enables :Jest command
let g:test#runner_commands = ['Jest']
" Tells vim test to use script defined in package.json
let g:test#javascript#jest#executable = 'yarn test'
let g:test#javascript#runner = 'jest'
" Only load jest
let g:test#enabled_runners =  ["javascript#jest"]
" This is a bit annoying, but is required to make vim-test work with monorepos. Essentially this will cd into the relevant package before running tests. Avoids 10k lines of empty output when jest is trying to run test in other packages.
augroup MonorepoPathsVimTest
  autocmd!
  autocmd BufEnter ~/code/sylvera-service/packages/monitoring/* let g:test#project_root = "~/code/sylvera-service/packages/monitoring"
  autocmd BufEnter ~/code/sylvera-service/packages/auth/* let g:test#project_root = "~/code/sylvera-service/packages/auth"
  autocmd BufEnter ~/code/sylvera-service/packages/cache-projects/* let g:test#project_root = "~/code/sylvera-service/packages/cache-projects"
  autocmd BufEnter ~/code/sylvera-service/packages/cognito/* let g:test#project_root = "~/code/sylvera-service/packages/cognito"
  autocmd BufEnter ~/code/sylvera-service/packages/container/* let g:test#project_root = "~/code/sylvera-service/packages/container"
  autocmd BufEnter ~/code/sylvera-service/packages/database-projects/* let g:test#project_root = "~/code/sylvera-service/packages/database-projects"
  autocmd BufEnter ~/code/sylvera-service/packages/emails/* let g:test#project_root = "~/code/sylvera-service/packages/emails"
  autocmd BufEnter ~/code/sylvera-service/packages/maps/* let g:test#project_root = "~/code/sylvera-service/packages/maps"
  autocmd BufEnter ~/code/sylvera-service/packages/notifications/* let g:test#project_root = "~/code/sylvera-service/packages/notifications"
  autocmd BufEnter ~/code/sylvera-service/packages/projects/* let g:test#project_root = "~/code/sylvera-service/packages/projects"
  autocmd BufEnter ~/code/sylvera-service/packages/shared/* let g:test#project_root = "~/code/sylvera-service/packages/shared"
  autocmd BufEnter ~/code/sylvera-service/packages/usage/* let g:test#project_root = "~/code/sylvera-service/packages/usage"
  autocmd BufEnter ~/code/sylvera-service/packages/users/* let g:test#project_root = "~/code/sylvera-service/packages/users"
  autocmd BufEnter ~/code/sylvera-service/packages/versions-service/* let g:test#project_root = "~/code/sylvera-service/packages/versions-service"
augroup END

augroup AsyncHook
  autocmd!
  autocmd User AsyncRunStop call TestFinished()
  autocmd User AsyncRunPre call TestStarted()
augroup END
" initially empty status
let g:testing_status = ''

function! TestStarted() abort
  let g:testing_status = 'Running ⌛'
endfunction

function! TestFinished() abort
  let job_status = g:asyncrun_status
  if job_status == "success"
    let g:testing_status = 'Complete ✅ ' 
  endif
  if job_status == "failure" 
    let g:testing_status = 'Failed ☠️ '
  endif
endfunction
" Used in lightline
function! TestStatus() abort
  return g:testing_status
endfunction
"" Tpipeline
let g:tpipeline_cursor_move=1
augroup Tpipeline
  autocmd!
  autocmd User CocDiagnosticChange call tpipeline#update()
  autocmd User CocStatusChange call tpipeline#update()
augroup END
"""""""""""""""""""""""
"  General settings  "
""""""""""""""""""""""""
set nocompatible
set encoding=utf-8
set autoindent
set hidden
set nobackup
set noshowcmd
set nowritebackup
set cmdheight=2
set noswapfile
set updatetime=300
set shortmess+=c
syntax on
 " Colorscheme and cursor
let g:solarized_termcolors=256
let g:jellybeans_use_term_background_color=0
let g:seoul256_background = 234
let g:seoul256_srgb = 1
set background=dark
colorscheme seoul256
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
set signcolumn=number
set textwidth=80
if has('nvim') || has('termguicolors')
  set termguicolors
endif
" Folding
set foldmethod=syntax
set foldlevel=99
" Disable statusline (embed in tmux status bar instead)
set noshowmode
set noruler
set laststatus=0
set noshowcmd
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
"" Leader key bindings
:let mapleader = ","
"Find and replace in a single file
:nnoremap <leader>r :%s/<c-r>=expand("<cword>")<cr>//g<Left><Left>
" Does the same as the above but works on visually selected text
:xnoremap <leader>r y<Esc>:%s/<C-R>"//g<Left><Left>
" Find in replace in multiple files - work in progress
:nnoremap <leader>R :Grep <c-r>=expand("<cword>")<cr><cr><cr>:cfdo %s/<c-r>=expand("<cword>")<cr>//ge \| cclose \| wa!<C-Left><C-Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
" Toggle quickfix
nnoremap <expr> <leader>cc empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'
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
nnoremap <leader>tl :TestLast<CR>
nnoremap <leader>tv :TestVisit<CR>
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
:nnoremap <silent> j gj
:nnoremap <silent> k gk
:nnoremap <silent> 0 g0
:nnoremap <silent> $ g$
:nnoremap <silent> 0 ^
:nnoremap <silent> ^ 0
" Copy current buffer's path
:nmap <silent> <leader>cpa :let @+ = expand("%")<CR>
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
:nnoremap <space>f :Rg<space>
"" CoC bindings
:nnoremap <silent> gd <Plug>(coc-definition)
:nnoremap <silent> gdv :call CocAction('jumpDefinition', 'vsplit')<cr>

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
"" Display branch symbol in statusline
function! FancyGitHead()
  return FugitiveHead()." ".""
endfunction

"" Add devicon to lightline
function! MyFileType()
  return winwidth(0) > 70 ? (WebDevIconsGetFileTypeSymbol(). " ". expand("%:t")) : ''
endfunction
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
  :iabbrev cla console.log();<Left><Left>
  :iabbrev ifa if() {<CR>}<Esc>%i<Left><Left>
  :iabbrev fua function() {<CR>}<Esc>%F(i
  :iabbrev afua async function() {<CR>}<Esc>%F(i
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
function! RipTest(...)
  let args = a:000
  let dir_param = args[-1] =~ 'in=*' ? split(args[-1], '=')[-1] : expand('%:p:h')
  let query = args[-2]
  "should extract into env variable
  let base_command ='rg --column --line-number --no-heading --color=always --smart-case %s || true'
endfunction
