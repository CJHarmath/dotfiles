"execute pathogen#infect()
syntax on
filetype plugin indent on
set number

" vim plug settings
call plug#begin('~/.vim/plugged')

" Themes
Plug 'morhetz/gruvbox'
Plug 'ayu-theme/ayu-vim'


"Plug 'junegunn/vim-easy-align'
"Plug 'scroolloose/nerdtree', {'on': 'NERDTreeToggle' }

" Syntax & Highlight
"
Plug 'digitaltoad/vim-pug' " Syntax for Pug
Plug 'ekalinin/Dockerfile.vim' " Syntax for Dockerfile
Plug 'gabrielelana/vim-markdown' " Syntax for Markdown
Plug 'jelera/vim-javascript-syntax' " Javascript syntax highlighting
Plug 'junegunn/goyo.vim' " Distraction free editing
Plug 'junegunn/limelight.vim' " Focus on paragraph under cursor
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'markcornick/vim-vagrant' " Vafrantfile syntax
Plug 'nathanaelkane/vim-indent-guides' " Tabs highlighting
Plug 'nikvdp/ejs-syntax' " Support for EJS syntax
Plug 'pangloss/vim-javascript' " Better indentation (jason0x43/vim-js-indent
" doesn't work with semi-less syntax)
Plug 'scrooloose/syntastic' " Check syntax with linters (for example:
" eslint)
Plug 'stephpy/vim-yaml' " Yaml syntax
Plug 'timakro/vim-searchant' " Highlight search match under cursor

" External tools
Plug 'airblade/vim-gitgutter' " Inline Git information

" Plugins
Plug 'editorconfig/editorconfig-vim' " Support editorconfig.org

call plug#end()

" from https://vimcolorschemes.com/morhetz/gruvbox

" Enable pretty colorscheme
syntax enable
set termguicolors " enable true colors support
set background=dark
colorscheme gruvbox

" Trigger autocomplete when enter dot (.)
if !exists("g:ycm_semantic_triggers")
 let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

