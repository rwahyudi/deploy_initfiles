" Vim configuration file

" No more "vi" compatibility
set nocompatible

" General vim stuff
filetype plugin on
filetype indent on
syntax on
syntax enable

" Default color
colorscheme desert
set background=dark

" Enable 256 colours terminal when possible 
set t_Co=256

" Set standard setting for PEAR coding standards
set tabstop=4
set shiftwidth=4
set expandtab

" Auto indenting is just so noice
set autoindent
set smartindent

" When searching in vim, make sure the search hit is never at the bottom
set scrolloff=5

" Source/reload .vimrc after saving .vimrc
autocmd bufwritepost .vimrc source $MYVIMRC

" Increase the history buffer for undo'ing mistakes
set history=1000
set undolevels=1000

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Status line
" Always show the status line
set laststatus=2

" Show nice info in ruler
set ruler

" Height of the command bar
set cmdheight=1

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Format the status line
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ %=\ Line:%l\/%L\ Column:%c%V\ %P

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2


" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%


" Default to paste nicely 
set paste