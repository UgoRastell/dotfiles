" ~/.vimrc — config pour 42 (C + Python)

" --- Général ---
set nocompatible
syntax on
filetype plugin indent on
set number				" numéros de ligne
set relativenumber		" numéros relatifs (pratique pour les sauts)
set mouse=a				" souris activée
set encoding=utf-8
set backspace=indent,eol,start
set scrolloff=5
set wildmenu			" menu de complétion en :commande
set incsearch			" recherche incrémentale
set hlsearch			" surligne les résultats
set showmatch			" montre la parenthèse correspondante
set laststatus=2		" barre de statut toujours visible
set ruler

" --- Norme 42 : tabulations réelles, largeur 4 ---
set noexpandtab			" vraies tabs (exigé par la norme en C)
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" --- Limite de 80 colonnes (norme 42) ---
set colorcolumn=80
highlight ColorColumn ctermbg=darkgray guibg=#3a3a3a

" --- Python : PEP8 (espaces, largeur 4) ---
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" --- Affiche les espaces en fin de ligne (interdits par la norme) ---
highlight TrailingWS ctermbg=red guibg=red
match TrailingWS /\s\+$/

" --- Header 42 (plugin 42header) ---
" F1 insère/met à jour le header, il se met aussi à jour à la sauvegarde
let g:user42 = 'ugo'
let g:mail42 = 'ugo@student.42.fr'

" --- Raccourcis pratiques ---
" F5 : compiler le fichier C courant avec les flags de la norme
autocmd FileType c nnoremap <F5> :w<CR>:!cc -Wall -Wextra -Werror % -o %:r && ./%:r<CR>
" F6 : lancer norminette sur le fichier courant
autocmd FileType c nnoremap <F6> :w<CR>:!norminette %<CR>
" F5 : exécuter le script Python courant
autocmd FileType python nnoremap <F5> :w<CR>:!python3 %<CR>
