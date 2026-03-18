" ========================
" Basic Settings
" ========================

set nocompatible              " Disable old vi compatibility
syntax on                     " Enable syntax highlighting
set number                    " Show line numbers
" set relativenumber            " Relative line numbers
" set cursorline                " Highlight current line
set showcmd                   " Show command in bottom bar
set showmatch                 " Highlight matching brackets
set ruler                     " Show cursor position

" ========================
" Indentation & Tabs
" ========================

set tabstop=4                 " A tab = 4 spaces
set shiftwidth=4              " Indent = 4 spaces
set expandtab                 " Use spaces instead of tabs
set smartindent               " Smart auto indentation
set autoindent

" ========================
" Search
" ========================

set ignorecase                " Case insensitive search
set smartcase                 " Case-sensitive if uppercase used
set incsearch                 " Show matches while typing
set hlsearch                  " Highlight search results

" ========================
" Appearance
" ========================

set termguicolors             " Enable 24-bit color (if supported)
set background=dark           " Use dark background
" colorscheme default           " Change if you install others

" ========================
" Behavior
" ========================

set backspace=indent,eol,start
set splitright                " Vertical splits open right
set splitbelow                " Horizontal splits open below
set hidden                    " Allow switching buffers without saving
" ========================
" Useful Key Mappings
" ========================

let mapleader = " "           " Leader key = Space

nnoremap <leader>w :w<CR>     " Save
nnoremap <leader>q :q<CR>     " Quit
nnoremap <leader>x :x<CR>     " Save & quit
nnoremap <leader>h :nohlsearch<CR>  " Clear search highlight

" Mirror yanks to the X clipboard when native +clipboard support is unavailable.
if executable('xclip')
  augroup system_clipboard_yank
    autocmd!
    autocmd TextYankPost * if v:event.operator is# 'y' |
          \ call system('xclip -in -selection clipboard', join(v:event.regcontents, "\n") . (v:event.regtype is# 'V' ? "\n" : '')) |
          \ endif
  augroup END

  " Paste from the system clipboard without needing "+p on Vim builds without +clipboard.
  nnoremap <leader>p :r !xclip -o -selection clipboard<CR>
  nnoremap <leader>P :put! =system('xclip -o -selection clipboard')<CR>
  inoremap <C-p> <C-r>=system('xclip -o -selection clipboard')<CR>
  vnoremap <leader>p c<C-r>=system('xclip -o -selection clipboard')<CR><Esc>
endif

" Quick escape from insert mode with 'jj'
inoremap jj <Esc>
