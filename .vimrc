packadd minpac
packadd matchit

set encoding=utf-8 fileencoding=utf-8

syntax on
filetype plugin indent on

" Plugins {{{

call minpac#init()

call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('christoomey/vim-tmux-navigator')
call minpac#add('danro/rename.vim')

call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-commentary')
call minpac#add('jiangmiao/auto-pairs')

call minpac#add('w0rp/ale')

" call minpac#add('SirVer/ultisnips')
call minpac#add('mattn/emmet-vim')
call minpac#add('tpope/vim-unimpaired')
call minpac#add('tpope/vim-repeat')

set runtimepath^=~/.fzf
call minpac#add('junegunn/fzf.vim')
call minpac#add('mhinz/vim-startify')

call minpac#add('pangloss/vim-javascript')
" call minpac#add('fatih/vim-go')
call minpac#add('dhruvasagar/vim-table-mode', {'type': 'opt'})
call minpac#add('plasticboy/vim-markdown')
call minpac#add('mzlogin/vim-markdown-toc')
call minpac#add('hail2u/vim-css3-syntax')
call minpac#add('othree/html5.vim')

" }}}


function! Strip(text)
    return substitute(a:text, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" Plugins settings {{{

let go_fmt_command = "goimports"

let tmux_navigator_no_mappings = 0

let startify_list_order = ['bookmarks', 'commands']

let table_mode_corner = '|'
let vim_markdown_frontmatter = 1

let ale_lint_on_text_changed = "never"
let ale_lint_on_enter = 0

let ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = { 'dir': '.git$\|node_modules$' }

let fzf_history_dir = '~/.local/share/fzf-history'

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

let g:UltiSnipsSnippetsDir='~/.vim/mysnippets'
let g:UltiSnipsSnippetDirectories=["mysnippets"]
let g:UltiSnipsEditSplit="horizontal"

" set cursor insert/normal in terminal
" if !has('gui_running')
"     let &t_ti.="\e[1 q"
"     let &t_SI.="\e[5 q"
"     let &t_EI.="\e[1 q"
"     let &t_te.="\e[0 q"
" endif

" }}}

colorscheme darkbase

" Options

set autowrite
set hidden
set lazyredraw
set autoread

set wildignore=node_modules/*

set noerrorbells " no sound from vim, it's a text editor, not a music player

set nospell spellfile="~/.vim/spell.utf-8.add"

set virtualedit=onemore " allow the cursor to move past the end of the line by one more char
set path=,,*
set ff=unix " set line endings to be unix
set tabstop=4 shiftwidth=4 shiftround
set wildmenu nolinebreak nowrap
set confirm " AWESOME!!

set smarttab expandtab copyindent autoindent " indentation stuff
set backspace=indent,eol,start
set list listchars=tab:\ \ ,nbsp:.,trail:·,eol:¬


" add backup files in a common directory to not pollute current directory
set backupdir=$HOME/.vim/.backups
set directory=$HOME/.vim/.swapfiles
set undofile undodir=$HOME/.vim/.undos

" prevent vim from auto inserting comment symbols
set formatoptions-=cro

" case insensitive if all lower case in search
set ignorecase smartcase

" keep the cursor away from the top/bottom with 5 lines when possible
set scrolloff=5

set nofoldenable foldcolumn=0 foldmethod=indent

set number numberwidth=5 " gutter options
" highlight live when searching and keep them on once I'm done
set incsearch hlsearch
" show currently typed letters bellow the status bar
set showcmd

" always show the status line
set laststatus=2

set statusline=

set statusline+=%{&readonly?'R':''}
set statusline+=%{&modifiable==0?'F':''}
set statusline+=%{&modified?'*':''}

set statusline+=%y
if &ff !=# 'unix'
    set statusline+=\ {%{&ff}}
endif
set statusline+=\ %.30F

" set statusline+=%y\ {%{&ff}}\ %.30F " [filetype] {lineendings} filepath

set statusline+=%= " go to the right side of the status line
set statusline+=\ %{wordcount()['words']}\ words\ \|
set statusline+=\ %l,\ %c " line and column
set statusline+=\ \|\ %p\ %%\ %L " location percentage of the file % line count

" default split position when :vsplit :split (feels more natural to me)
set splitbelow splitright

set mouse=

function! BuildPython(test)
    silent execute "!clear"
    if a:test && filereadable('./tests/main.py')
        execute "!python tests/main.py"
    elseif filereadable('./main.py')
        execute "!python main.py"
    else
        execute "!python ".bufname("%")
    endif
endfunction

function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

function! NextNonBlankLine(lnum)
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction

function! FoldFunctions(lnum)
    let l:line = getline(a:lnum)
    let l:nextlinenum = NextNonBlankLine(a:lnum)
    let l:nextline = getline(l:nextlinenum)

    if l:line =~# '\v\s*def .*'
        let b:functionindentlevel=IndentLevel(a:lnum)
        return '1'
    endif

    if l:line =~? '\v^\s*$'
        if l:nextline =~# '\v\s*def .*' || IndentLevel(l:nextlinenum) == 0
            let b:functionindentlevel = -1
            return '0'
        endif
        return '-1'
    endif

    if IndentLevel(a:lnum) > 0:
        return '-1'
    endif

    if b:functionindentlevel != -1
        return '1'
    endif
    return '-1'
endfunction

function! Rjust(string, width, fill)
    let l:string = a:string
    while strlen(l:string) < a:width
        let l:string = l:string . a:fill
    endwhile
    return l:string
endfunction

function! FoldText()
    let l:line = Rjust(getline(v:foldstart) . ' ', 80, '-')
    let l:index = 0
    let l:char = l:line[l:index]
    while char == ' '
        let l:index = l:index + 1
        let l:char = l:line[l:index]
    endwhile
    let l:space = ' '
    if l:index == 0
        let l:space = ''
    endif
    return repeat('-', l:index - 1) . l:space . l:line[index:]
endfunction

" abbreviations
iabbrev lable label
iabbrev teh the

function! FileTypeSetup(name)
    if a:name ==# 'markdown'
        setlocal spell wrap
        iabbrev <buffer> repo repository
        nnoremap <buffer> <leader>* viw*esc>a*<esc>bi*<esc>lel
        nnoremap <buffer> <leader>f :call InsertTipFrontMatter()<CR>
        iabbrev env environment
        iabbrev gov government
        iabbrev bu business
        packadd vim-table-mode
        setlocal textwidth=80
        silent TableModeEnable
    elseif a:name ==# 'css'
        setlocal tabstop=2 shiftwidth=2
    elseif a:name ==# 'python'
        let b:functionindentlevel = -1
        setlocal foldmethod=expr
        setlocal foldexpr=FoldFunctions(v:lnum)
        setlocal foldtext=FoldText()
        execute 'setlocal fillchars+=fold:\ '
        nnoremap <buffer> <leader>b :call BuildPython(0)<CR>
        nnoremap <buffer> <leader>r :call BuildPython(1)<CR>
        nnoremap <buffer> M :BLines def <CR>
        setlocal colorcolumn=81
        iabbrev <buffer> yeild yield
        ALEDisable
    elseif a:name ==# 'html'
        iabbrev <buffer> --- &mdash;
        setlocal nowrap
        imap <buffer> <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
    elseif a:name ==# 'javascript'
        nnoremap <buffer> <leader>b :call Build('node')<cr>
        iabbrev <buffer> len length
    elseif a:name ==# 'sh'
        nnoremap <buffer> <leader>b :call Build('bash')<cr>
    elseif a:name ==# 'vim'
        nnoremap <buffer> <leader>b :source %<cr>
    elseif a:name ==# 'qf'
        nnoremap <buffer> j j
        nnoremap <buffer> k k
    elseif a:name ==# 'gitconfig'
        setlocal nospell
    elseif a:name ==# 'go' " golang
        nnoremap <leader>b :GoRun<CR>
        nnoremap <leader>b :!go run main.go<CR>
        nnoremap <leader>v :!go run %<CR>
        nnoremap <C-u> :GoDoc<CR>
        set nospell
    elseif a:name ==# 'tmux'
        setlocal nospell
    elseif a:name ==# 'yaml'
        setlocal tabstop=2 shiftwidth=2
        setlocal nospell
    elseif a:name ==# 'pascal'
        setlocal makeprg=~/run-pascal.sh\ %
    endif
endfunction

command! FileTypeSetup call FileTypeSetup(&filetype)

augroup autocmds
    au!
    " fix vim bug: open all .md files as markdown
    au BufNewFile,BufRead *.md setlocal filetype=markdown
    au FileType * call FileTypeSetup(expand('<amatch>'))
    " remove trailling white spaces
    au BufWritePre * %s/\s\+$//e

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    " - from defaults.vim (/usr/share/vim/vim80/defaults.vim)
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

    " autocmd BufWritePost *.go :silent !goimports -w %
augroup end

" keybindings

let mapleader=","

nnoremap <space> za
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" run nohlsearch as soon as we enter insert mode (noh doesn't work in
" autocommands)
for s:c in ['a', 'A', '<Insert>', 'i', 'I', 'gI', 'gi', 'o', 'O']
    exe 'nnoremap ' . s:c . ' :nohlsearch<CR>' . s:c
endfor

" paste from actual clipboard
nnoremap <silent> <leader>p :let @z=system('xclip -selection clipboard -o')<CR>"zp
nnoremap <silent> <leader>P :let @z=system('xclip -selection clipboard -o')<CR>"zP

vnoremap <silent> <leader>y :<home>silent <End>w !xclip -selection clipboard<CR>
nnoremap <silent> <leader>y V:<home>silent <End>w !xclip -selection clipboard<CR>

" center the search result on the screen
nnoremap n nzz
nnoremap N Nzz

nnoremap <leader>a :ALENextWrap<CR>

" 'cause that's how you learn
inoremap <esc> <Nop>

nnoremap <leader>b :make!<CR>

nnoremap <leader>h :nohlsearch<CR>

inoremap <C-a> <HOME>
inoremap <C-b> <C-o>b
inoremap <C-f> <C-o>w

" nnoremap <C-j> <C-e>
" nnoremap <C-k> <C-y>

" 'cause I'm lazy...
inoremap jk <Esc>

" to consider wrapped lines as actual lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

nnoremap <leader>s :call ScopeInfos()<CR>
nnoremap <F6> :set spell!<CR>:set spell?<CR>

nnoremap <leader>l :autocmd TextChanged,TextChangedI <buffer> write<CR>

nmap <leader>c m`gcc``
vmap <leader>c gc

" duplicate selection
vnoremap <leader>d "yy'>"yp
nnoremap <leader>d mz"yyy"yp`zj

nnoremap <leader>q q:kk

nnoremap <silent> <leader>w :call ToggleHighlightWordUnderCursor()<CR>
nnoremap <silent> <leader>W :match none<CR>

nnoremap <C-p> :Files<CR>

nnoremap : ;
nnoremap ; :
vnoremap ; :
vnoremap : ;

nnoremap \ ;
nnoremap \| ,

" keep position on the line (use ` instead of ')
nnoremap z. mzz.`z
" don't save to register when using x
" nnoremap x "_x
" visualize pasted text
nnoremap gp `[v`]

nnoremap <leader>eV :call DynamicOpen($MYVIMRC)<cr>
nnoremap <leader>ev :call DynamicOpen("~/dotfiles/.vimrc")<cr>
nnoremap <leader>eB :call DynamicOpen("~/.bashrc")<cr>
nnoremap <leader>eb :call DynamicOpen("~/dotfiles/.bashrc")<cr>
nnoremap <leader>eT :call DynamicOpen("~/.tmux.conf")<cr>
nnoremap <leader>et :call DynamicOpen("~/dotfiles/.tmux.conf")<cr>
nnoremap <leader>eg :call DynamicOpen($MYGVIMRC)<cr>

augroup autoreloadconfigfiles
    autocmd!
    autocmd BufWritePost .vimrc source ~/.vimrc
    if has("gui_running")
        autocmd BufWritePost $MYGVIMRC source ~/.vimrc
    endif
    autocmd BufWritePost .tmux.conf silent! !tmux source-file ~/.tmux.conf
    autocmd BufWritePost ~/.vim/colors/*.vim :so <afile>
augroup end

" functions

function! GetFormattedDate()
    return Strip(system("date +'%A %d %B %Y'"))
endfunction



function! BangLastCommand()
    let lastcommand = split(@:, ' ')
    let command = lastcommand[0] . '! ' . join(lastcommand[1:], ' ')
    execute command
endfunction

command! Please call BangLastCommand()

function! InsertTipFrontMatter()
    let date = GetFormattedDate()
    call Insert("---\ntitle: \nslug: \ntags: \ndate: ".date."\nplace: \n---\n\n")
    execute "normal! ?title:\<CR>A "
    start
endfunction

function! DynamicOpen(file)
    if winwidth(win_getid()) > 160
        execute "vsplit ".a:file
    else
        execute "tabe ".a:file
    endif
endfunction

function! ScopeInfos()
    let synid = synIDtrans(synID(line('.'), col('.'), 1))
    echo printf('Syntax name: "%s" | fg: %s bg: %s', synIDattr(synid, 'name'),  synIDattr(synid, 'fg#'), synIDattr(synid, 'bg#'))
endfunction

function! Insert(text)
    " a simple function to insert text where the cursor is
    execute "normal! \<Esc>a".a:text
endfunction

function! ToggleHighlightWordUnderCursor()
    let matches = getmatches()
    let cword = expand('<cword>')
    if !empty(matches) && printf('\<%s\>', cword) ==# matches[0]['pattern']
        match none
        echo "Matches cleared"
    else
        silent! exe printf('match IncSearch /\<%s\>/', cword)
        redir => nbmatches
            silent! exe "%s/".cword."//gn"
        redir END
        let nbmatches = str2nr(Strip(split(nbmatches, ' ')[0]))
        echo printf('Found %s match%s', nbmatches, nbmatches > 1 ? 'es' : '')
        " move cursor back to its previous position
        execute "normal! \<C-o>"
    endif
endfunction

function! EscapeHTML() range
    execute a:firstline.",".a:lastline."s/\</\\&lt;/g"
    execute a:firstline.",".a:lastline."s/\>/\\&gt;/g"
endfunction

" commands

command! RemoveWindowsLineEndings :%s/\r\(\n\)/\1/g
command! Date :call Insert(Strip(GetFormattedDate()))
command! -range=% EscapeHTML :call EscapeHTML()

if has('gui_running') && glob('~/.gvimrc') != ''
    source ~/.gvimrc
endif

command! HugoDebug :call Insert('<code>{{ printf "%#v" . }}</code>') |
            \ :normal "bbbb"
command! HugoMore :call Insert("<!--more-->")

command! PackUpdate :call minpac#update()
command! PackClean :call minpac#clean()
