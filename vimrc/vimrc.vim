"" Vimrc file
" Author: Mansour Alharthi <man9our.ah@gmail.com>

set nocompatible              " be iMproved, required
syntax on
set hlsearch
set incsearch
filetype off                  " required
set backspace=indent,eol,start
set encoding=utf-8
set termguicolors
colorscheme pure-blue

""""""""""""""""""""""""""""""""""""""" Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'

Plugin 'nathanaelkane/vim-indent-guides'

Plugin 'easymotion/vim-easymotion'

Plugin 'man9ourah/taglist.vim'

Plugin 'man9ourah/vim-markdown-preview'

Plugin 'man9ourah/long-statusline'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""" Column for text files
au BufRead,BufNewFile *.txt setlocal colorcolumn=80 spell
au BufRead,BufNewFile text setlocal colorcolumn=80 spell
au BufRead,BufNewFile *.tex setlocal colorcolumn=80 spell
au BufRead,BufNewFile *.md setlocal colorcolumn=80 spell
au BufRead,BufNewFile *.rst setlocal colorcolumn=80 spell

""""""""""""""""""""""""""""""""""""""" Easymotion
" Move to word
map <Leader>w <Plug>(easymotion-bd-w)

"""""""""""""""""""""""""""""""""""""""" YCM
let g:ycm_filetype_blacklist = {
      \ 'tagbar': 1,
      \ 'notes': 1,
      \ 'netrw': 1,
      \ 'unite': 1,
      \ 'text': 1,
      \ 'vimwiki': 1,
      \ 'pandoc': 1,
      \ 'infolog': 1,
      \ 'mail': 1,
      \}
let g:ycm_complete_in_comments = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_auto_trigger = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_goto_buffer_command = 'split'
let g:ycm_always_populate_location_list = 1
nnoremap <silent> <c-u> :YcmCompleter GoTo<CR>
nnoremap <silent> <c-i> :YcmCompleter FixIt<CR>
nmap <c-@> <plug>(YCMHover)

"""""""""""""""""""""""""""""""""""""""" IndentGuides
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size = 1

"""""""""""""""""""""""""""""""""""""""" Taglist
let Tlist_Auto_Open=1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Auto_Highlight_Tag = 1
let Tlist_Use_SingleClick = 1
let Tlist_Show_One_File = 1
let Tlist_Enable_Fold_Column = 0
nnoremap <silent> <c-up> :call Tlist_Jump_Prev_Tag()<CR>
nnoremap <silent> <c-down> :call Tlist_Jump_Next_Tag()<CR>

""""""""""""""""""""""""""""""""""""""" Vim Markdown
"" We changed the code tailoring our options!!
" if we need to change options we need to revisit the code
let vim_markdown_preview_toggle=2
let vim_markdown_preview_github=1
let vim_markdown_preview_browser='Mozilla Firefox'
let vim_markdown_preview_temp_file=1
let vim_markdown_preview_sleep='500m'

""""""""""""""""""""""""""""""""""""""" Misc.
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
set nu
set clipboard=unnamedplus
" :W -> :w
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
" :Q -> :q
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
" signal column
set signcolumn=no
" backup & swap
set nobackup
set noswapfile
" scroll offset
set scrolloff=4
set sidescrolloff=4
" Garbage text
set t_TI= t_TE=
" Default update time it too long! (=4000)
set updatetime=2000
" Refresh tagslist
nnoremap <silent> <f5> :TlistUpdate<CR>
nnoremap <silent> <f2> :nohls<CR>

""""""""""""""""""""""""""""""""""""""" Persistent undo
if has('persistent_undo')
  set undodir=$HOME/.vim/undo
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

""""""""""""""""""""""""""""""""""""""" On-demand spellcheck
function OnDemandSpellCheck(word)
    let s:sugg = system("echo ".a:word." | aspell -a | sed -n -e '2{p;q}' | tr -d '\n'")
    if (s:sugg == '*')
        echo "*"
        return
    endif
    let s:startSugg = stridx(s:sugg, ":")
    if (s:startSugg != -1)
        echohl WarningMsg | echo "Suggestions" . strpart(s:sugg, s:startSugg) | echohl None
    endif
endfunction
nnoremap <silent><c-s> :call OnDemandSpellCheck(expand("<cword>"))<CR>

