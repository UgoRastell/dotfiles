# ~/.zshrc — config zsh orientée 42 (portable)
# Repo : https://github.com/UgoRastell/dotfiles

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

# ── Complétion ────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                        # menu navigable aux flèches
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'    # insensible à la casse
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── Touches ───────────────────────────────────────────────────
bindkey -e                                    # mode emacs (défaut familier)
bindkey '^[[1;5C' forward-word                # Ctrl+→
bindkey '^[[1;5D' backward-word               # Ctrl+←
bindkey '^[[3~'   delete-char                 # Suppr
bindkey '^[[H'    beginning-of-line           # Début
bindkey '^[[F'    end-of-line                 # Fin

# ── Plugins (chemins selon la distro, sourcés seulement si présents) ──
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
alias vg='valgrind --leak-check=full --show-leak-kinds=all'
[ -f ~/mini-moulinette/mini-moul.sh ] && alias mini=~/mini-moulinette/mini-moul.sh

# Tests de la libft (francinette est archivée depuis déc. 2024 et ne marche plus).
# Le tester vit hors du projet : rien à ignorer dans le dépôt de rendu.
#   libfttest          → toutes les fonctions
#   libfttest split    → une seule
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
	cc -Wall -Wextra -Werror "$1" -o /tmp/cr_out && /tmp/cr_out "${@:2}"
}

# Installe le hook pre-commit (norminette) dans le dépôt courant.
# Les nouveaux dépôts l'ont déjà via init.templateDir ; ceci sert aux anciens.
42hook() {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null) || {
		echo "Pas dans un dépôt git."; return 1
	}
	cp ~/dotfiles/git/template/hooks/pre-commit "$root/.git/hooks/pre-commit" &&
		chmod +x "$root/.git/hooks/pre-commit" &&
		echo "✓ hook pre-commit installé dans $root"
}

# Dépose le template de Makefile 42 dans le dossier courant
42make() {
	[ -e Makefile ] && { echo "Makefile déjà présent, rien fait."; return 1; }
	cp ~/dotfiles/templates/Makefile . &&
		echo "✓ Makefile créé — ajuste NAME et SRCS."
}

# ── Prompt (starship si dispo, sinon prompt zsh simple) ───────
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"
else
	PROMPT='%F{cyan}%2~%f %F{green}❯%f '
fi
