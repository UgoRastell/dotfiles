# ~/.zshrc — config zsh orientée 42 (portable)
# Repo : https://github.com/UgoRastell/dotfiles

# Racine du dépôt, retrouvée en suivant le lien ~/.zshrc → <repo>/zsh/.zshrc :
# marche quel que soit l'endroit où le dépôt a été cloné.
DOTFILES=${${(%):-%x}:A:h:h}

# ~/.local/bin : là où atterrissent norminette (pip/pipx) et starship installés
# sans sudo. zsh ne lit pas ~/.profile, il faut donc l'ajouter ici.
typeset -U path               # pas de doublons dans le PATH
path=(~/.local/bin $path)

# ── Historique ────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # historique partagé entre les terminaux
setopt HIST_IGNORE_ALL_DUPS   # pas de doublons
setopt HIST_IGNORE_SPACE      # une commande précédée d'un espace n'est pas enregistrée

# ── Confort ───────────────────────────────────────────────────
setopt AUTO_CD                # taper un chemin suffit pour cd
setopt CORRECT                # propose une correction si commande mal tapée
setopt INTERACTIVE_COMMENTS   # autorise les # commentaires dans le terminal

# ── Couleurs (palette Catppuccin Mocha, partagée avec starship et vim) ──
command -v dircolors >/dev/null && eval "$(dircolors -b)"   # définit LS_COLORS
export LESS_TERMCAP_md=$'\e[1;35m'    # man : titres en mauve
export LESS_TERMCAP_us=$'\e[4;36m'    # man : arguments soulignés en cyan
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_me=$'\e[0m'
export GROFF_NO_SGR=1                 # sinon les couleurs ci-dessus sont ignorées

# ── Complétion ────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                        # menu navigable aux flèches
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'    # insensible à la casse
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''                      # regroupe par catégorie…
zstyle ':completion:*:descriptions' format '%F{magenta}── %d ──%f'   # …avec un titre
zstyle ':completion:*:warnings' format '%F{red}── aucun résultat ──%f'

# ── Touches ───────────────────────────────────────────────────
bindkey -e                                    # mode emacs (défaut familier)
bindkey '^[[1;5C' forward-word                # Ctrl+→
bindkey '^[[1;5D' backward-word               # Ctrl+←
bindkey '^[[3~'   delete-char                 # Suppr
bindkey '^[[H'    beginning-of-line           # Début
bindkey '^[[F'    end-of-line                 # Fin

# ── Plugins (chemins selon la distro, sourcés seulement si présents) ──
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'  # suggestion discrète (overlay0)
for f in \
	/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
	/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
	~/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
	[ -f "$f" ] && source "$f" && break
done
# syntax-highlighting doit être sourcé EN DERNIER des plugins
for f in \
	/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	~/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
	[ -f "$f" ] && source "$f" && break
done

# ── Alias généraux ────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'

# ── Alias 42 ──────────────────────────────────────────────────
alias norm='norminette'
alias ccw='cc -Wall -Wextra -Werror'
alias vg='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes'
[ -f ~/mini-moulinette/mini-moul.sh ] && alias mini=~/mini-moulinette/mini-moul.sh

# Tests de la libft (francinette est archivée depuis déc. 2024 et ne marche plus).
# Le tester vit hors du projet : rien à ignorer dans le dépôt de rendu.
#   libfttest          → partie obligatoire
#   libfttest b        → bonus      (a → tout)
#   libfttest split    → une seule fonction
libfttest() {
	[ -f libft.h ] || {
		echo "libft.h introuvable — à lancer depuis ton dossier libft."; return 1
	}
	[ -d ~/libftTester ] ||
		git clone -q https://github.com/Tripouille/libftTester.git ~/libftTester ||
		return 1
	make -C ~/libftTester LIBFT_PATH="$PWD" "${@:-m}"
}

# Compile + exécute d'un coup : cr main.c [args...]
cr() {
	[ -n "$1" ] || { echo "usage : cr fichier.c [args...]"; return 1; }
	local out="${TMPDIR:-/tmp}/cr_$$"
	cc -Wall -Wextra -Werror "$1" -o "$out" && "$out" "${@:2}"
	local ret=$?
	rm -f "$out"
	return $ret
}

# Installe le hook pre-commit (norminette) dans le dépôt courant.
# Les nouveaux dépôts l'ont déjà via init.templateDir ; ceci sert aux anciens.
42hook() {
	local hooks
	# --git-path gère aussi les worktrees et sous-modules, où .git est un fichier
	hooks=$(git rev-parse --path-format=absolute --git-path hooks 2>/dev/null) || {
		echo "Pas dans un dépôt git."; return 1
	}
	mkdir -p "$hooks" &&
		cp "$DOTFILES/git/template/hooks/pre-commit" "$hooks/pre-commit" &&
		chmod +x "$hooks/pre-commit" &&
		print -P "%F{green}✓%f hook pre-commit installé dans $hooks"
}

# Dépose le template de Makefile 42 dans le dossier courant
42make() {
	[ -e Makefile ] && { echo "Makefile déjà présent, rien fait."; return 1; }
	cp "$DOTFILES/templates/Makefile" . &&
		print -P "%F{green}✓%f Makefile créé — ajuste NAME et SRCS."
}

# ── Prompt (starship si dispo, sinon équivalent en zsh pur) ───
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"
else
	autoload -Uz vcs_info
	zstyle ':vcs_info:git:*' formats $' %F{magenta} %b%f'
	precmd() { vcs_info }
	setopt PROMPT_SUBST
	PROMPT=$'%F{8}╭─%f %B%F{blue}%3~%f%b${vcs_info_msg_0_}\n%F{8}╰─%f%(?.%F{green}.%F{red})❯%f '
fi
