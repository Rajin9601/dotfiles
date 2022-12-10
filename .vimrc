call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-rails'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'itchyny/lightline.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'valloric/youcompleteme'
Plug 'danro/rename.vim'
call plug#end()

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

nmap <F7> :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>
nmap <c-n> :NERDTreeFocus<CR>
nmap , @@

autocmd BufWritePre * StripWhitespace

let g:tagbar_ctags_bin="~/Lib/ctags"

set backspace=indent,eol,start

set number
set cindent
set ai
set si
set ignorecase
set hlsearch
set expandtab
set shiftwidth=2
set tabstop=2
set sts=2
set history=1000
set ruler
set showmatch
set title
set wmnu
set mouse=a
set clipboard=unnamed
set background=dark
syntax on

vnoremap p pgvy

