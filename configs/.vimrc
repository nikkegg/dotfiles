""""""""""""""""""""""""
"  Plugins  "
""""""""""""""""""""""""

call plug#begin()
  Plug 'ghifarit53/tokyonight-vim'
  Plug 'lambdalisue/fern.vim'
  Plug 'lambdalisue/nerdfont.vim'
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/fern-git-status.vim'
  Plug 'junegunn/fzf.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " Modify * to also work with visual selections.
  Plug 'nelstrom/vim-visual-star-search'
  " Automatically clear search highlights after you move your cursor.
  Plug 'haya14busa/is.vim'
  Plug 'sheerun/vim-polyglot'
  Plug 'embark-theme/vim', { 'as': 'embark', 'branch': 'main' } 
  Plug 'itchyny/lightline.vim'
  Plug 'tmux-plugins/vim-tmux'
  Plug 'vim-test/vim-test'
  Plug 'junegunn/goyo.vim'
  Plug 'junegunn/limelight.vim'
  Plug 'christoomey/vim-system-copy'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'tpope/vim-commentary'
  Plug 'zivyangll/git-blame.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'tpope/vim-repeat' 
  Plug 'tpope/vim-repeat' 
  Plug 'kana/vim-textobj-user'
  Plug 'kana/vim-textobj-line'
  Plug 'kana/vim-textobj-indent'
  Plug 'andyl/vim-textobj-elixir'
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


"" Coc-general
""" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

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
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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
let g:coc_config_home = '/usr/local/opt/dotfiles/configs/'
"" Status line
""" Displays numbers of errors and warnings as well as corresponding coc icongs in the statusline
function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

  function! s:lightline_coc_diagnostic(kind, sign) abort
    let info = get(b:, 'coc_diagnostic_info', 0)
    if empty(info) || get(info, a:kind, 0) == 0
      return ''
    endif
    return printf('%s %d', a:sign, info[a:kind])
  endfunction
  function! LightlineCocErrors() abort
    return s:lightline_coc_diagnostic('error', 'E')
  endfunction
  function! LightlineCocWarnings() abort
    return s:lightline_coc_diagnostic('warning', 'W')
  endfunction
  function! LightlineCocInfos() abort
    return s:lightline_coc_diagnostic('information', 'I')
  endfunction
  function! LightlineCocHints() abort
    return s:lightline_coc_diagnostic('hints', 'H')
  endfunction

let g:lightline = {
  \ 'colorscheme': 'embark',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'readonly', 'filename', 'modified', 'coc_error', 'coc_warning', 'coc_hint', 'coc_info' ] ],
	\   'right': [ [ 'lineinfo',  ],
	\              [ 'percent' ],
	\              [ 'fileformat', 'fileencoding', 'gitbranch'] ]
	\ },
  \ 'component_expand': {
  \   'coc_error'        : 'LightlineCocErrors',
  \   'coc_warning'      : 'LightlineCocWarnings',
  \   'coc_info'         : 'LightlineCocInfos',
  \   'coc_hint'         : 'LightlineCocHints',
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead'
  \ },
  \ }
let g:lightline.component_type = {
\   'coc_error'        : 'error',
\   'coc_warning'      : 'warning',
\   'coc_info'         : 'tabsel',
\   'coc_hint'         : 'middle',
\ }

augroup update_status_line
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
  autocmd VimEnter * call lightline#update()
augroup END
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
cnoreabbrev <expr> gp (getcmdtype() ==# ':' && getcmdline() ==# 'gfp')  ? 'G push' : 'gp'
cnoreabbrev <expr> gpull (getcmdtype() ==# ':' && getcmdline() ==# 'gpull')  ? 'G pull' : 'gpull'
cnoreabbrev <expr> grb (getcmdtype() ==# ':' && getcmdline() ==# 'grb')  ? 'G rebase -i origin/master' : 'grb'
cnoreabbrev <expr> ga (getcmdtype() ==# ':' && getcmdline() ==# 'ga')  ? 'G add --patch' : 'ga'
cnoreabbrev <expr> gc (getcmdtype() ==# ':' && getcmdline() ==# 'gc')  ? 'G commit' : 'ga'
cnoreabbrev <expr> stash (getcmdtype() ==# ':' && getcmdline() ==# 'stash')  ? 'G stash' : 'stash'
"" Command mode aliases to mirror .gitconfig

"""""""""""""""""""""""
"  General settings  "
""""""""""""""""""""""""
set encoding=utf-8
set autoindent
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
syntax on
colorscheme embark
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set autoindent
set autoread
set backspace=indent,eol,start
set cursorline
set hlsearch
set ignorecase
set incsearch
set nocompatible
set noerrorbells visualbell t_vb=
set number relativenumber
set laststatus=2
if has('nvim') || has('termguicolors')
  set termguicolors
endif

"" Temporary Grep whilst I am figuring out fzf
set grepprg=rg\ --vimgrep

function! Grep(...)
	return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
	autocmd!
	autocmd QuickFixCmdPost cgetexpr cwindow
	autocmd QuickFixCmdPost lgetexpr lwindow
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
:nnoremap <leader>cc :cclose<cr>
:nnoremap <leader>d dd
:nnoremap <leader>ev :vsplit /usr/local/opt/dotfiles/configs/.vimrc<cr>
:nnoremap <leader>sv :source /usr/local/opt/dotfiles/configs/.vimrc<cr>
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
:nnoremap <space>p :FZF -m<CR>
:nnoremap <space>f :Rg<space>
"" CoC bindings
:nnoremap <silent> gd <Plug>(coc-definition)
:nnoremap <silent> gdv :call CocAction('jumpDefinition', 'vsplit')<cr>
""""""""""""""""""""""""
"  Custom functions  "
""""""""""""""""""""""""
"" CD into current working directory
" this is use on configs start-up to switch root directory to dotfiles
function CdPWD()
  :cd %:p:h
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

