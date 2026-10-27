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
set splitright splitbelow	" les nouveaux splits s'ouvrent à droite / en bas

" --- Norme 42 : tabulations réelles, largeur 4 ---
set noexpandtab			" vraies tabs (exigé par la norme en C)
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" --- Limite de 80 colonnes (norme 42) ---
" La 80e colonne est encore autorisée : on marque la 81e, la première en trop.
set colorcolumn=81

" --- Apparence (palette Catppuccin Mocha, comme le prompt starship) ---
" Le thème catppuccin exige les vraies couleurs (24 bits) ; sinon habamax,
" livré avec vim 9, rend bien en 256 couleurs.
if has('termguicolors') && ($COLORTERM =~# 'truecolor\|24bit' || !empty($WT_SESSION))
	set termguicolors
endif
set cursorline
silent! set cursorlineopt=number		" surligne juste le numéro de la ligne courante
silent! set fillchars=vert:│,eob:\ 	" séparateur fin, pas de ~ après la fin du fichier
" Tabs visibles en discret (on distingue tab et espaces, utile pour la norme),
" espaces en fin de ligne marqués d'un point.
set list listchars=tab:│\ ,trail:·,nbsp:␣

" Nos couleurs sont redéfinies à chaque changement de thème, sinon il les efface.
augroup dotfiles_colors
	autocmd!
	autocmd ColorScheme * call s:Colors()
augroup END

function! s:Colors() abort
	highlight ColorColumn  ctermbg=236 guibg=#313244
	highlight TrailingWS   ctermbg=red guibg=#f38ba8
	highlight SpecialKey   ctermfg=238 guifg=#45475a
	highlight! link NonText SpecialKey
	highlight StlNormal    cterm=bold ctermfg=234 ctermbg=111 gui=bold guifg=#1e1e2e guibg=#89b4fa
	highlight StlInsert    cterm=bold ctermfg=234 ctermbg=150 gui=bold guifg=#1e1e2e guibg=#a6e3a1
	highlight StlVisual    cterm=bold ctermfg=234 ctermbg=183 gui=bold guifg=#1e1e2e guibg=#cba6f7
	highlight StlReplace   cterm=bold ctermfg=234 ctermbg=211 gui=bold guifg=#1e1e2e guibg=#f38ba8
	highlight StlFile      ctermfg=189 ctermbg=236 guifg=#cdd6f4 guibg=#313244
	highlight StlInfo      ctermfg=146 ctermbg=235 guifg=#a6adc8 guibg=#181825
endfunction

if &termguicolors
	try
		colorscheme catppuccin_mocha
	catch
		silent! colorscheme habamax
	endtry
else
	silent! colorscheme habamax
endif
call s:Colors()		" au cas où aucun thème n'a été chargé

" --- Barre de statut : mode coloré | fichier | type, encodage, position ---
set laststatus=2
set noshowmode			" le mode est déjà dans la barre
function! StlMode() abort
	let l:m = mode()
	if l:m ==# 'i'
		return '%#StlInsert# INSERT '
	elseif l:m =~# '[vV]' || l:m ==# "\<C-v>"
		return '%#StlVisual# VISUEL '
	elseif l:m ==# 'R'
		return '%#StlReplace# REMPL. '
	endif
	return '%#StlNormal# NORMAL '
endfunction
set statusline=%{%StlMode()%}%#StlFile#\ %f\ %m%r%=%#StlInfo#\ %{&ft}\ │\ %{&fenc}\ │\ %l:%c\ \ %p%%\ %*

" --- Affiche les espaces en fin de ligne (interdits par la norme) ---
" :match est propre à une fenêtre : on le réapplique à chaque fenêtre ouverte.
augroup dotfiles_trailing
	autocmd!
	autocmd BufWinEnter,WinNew * match TrailingWS /\s\+$/
augroup END

" --- Python : PEP8 (espaces, largeur 4) ---
augroup dotfiles_python
	autocmd!
	autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
augroup END

" --- Header 42 (plugin 42header) ---
" F1 insère/met à jour le header, il se met aussi à jour à la sauvegarde
let g:user42 = 'ugo'
let g:mail42 = 'ugo.rastell@learner.42.tech'

" --- Raccourcis pratiques ---
" <buffer> : chaque raccourci ne vaut que pour le fichier où il a été défini,
" sinon ouvrir un .py ferait lancer python3 sur les .c avec F5.
augroup dotfiles_keys
	autocmd!
	" F5 : compiler le fichier C courant avec les flags de la norme, puis l'exécuter
	autocmd FileType c nnoremap <buffer> <F5> :w<CR>:!cc -Wall -Wextra -Werror %:S -o %:r:S && %:p:r:S<CR>
	" F6 : lancer norminette sur le fichier courant
	autocmd FileType c nnoremap <buffer> <F6> :w<CR>:!norminette %:S<CR>
	" F5 : exécuter le script Python courant
	autocmd FileType python nnoremap <buffer> <F5> :w<CR>:!python3 %:S<CR>
augroup END
