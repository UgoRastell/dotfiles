#!/bin/sh
# Installe les dotfiles par liens symboliques.
# Usage : git clone https://github.com/UgoRastell/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

# Couleurs seulement dans un vrai terminal (pas si la sortie est redirigée)
if [ -t 1 ]; then
	E=$(printf '\033')
	G="$E[32m" Y="$E[33m" B="$E[34m" M="$E[35m" D="$E[2m" R="$E[0m"
else
	G='' Y='' B='' M='' D='' R=''
fi
ok()      { printf "  ${G}✓${R} %s\n" "$*"; }
warn()    { printf "  ${Y}→${R} %s\n" "$*"; }
section() { printf "\n${M}── %s${R}\n" "$*"; }

printf "${B}dotfiles${R} ${D}— zsh · starship · vim · norme 42${R}\n"

link() {
	src="$1"; dst="$2"
	mkdir -p "$(dirname "$dst")"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		mv "$dst" "$dst.bak"
		warn "$dst existant sauvegardé en $dst.bak"
	fi
	ln -sf "$src" "$dst"
	ok "$dst ${D}→ $src${R}"
}

# Clone un plugin vim s'il n'est pas déjà là ; sans réseau, vim marche sans.
vim_plugin() {
	name="$1"; url="$2"
	target="$HOME/.vim/pack/dotfiles/start/$name"
	if [ -d "$target" ] || [ -d "$HOME/.vim/pack/42/start/$name" ]; then
		ok "plugin $name déjà présent"
	elif command -v git >/dev/null 2>&1 && git clone -q --depth 1 "$url" "$target"; then
		ok "plugin $name installé"
	else
		warn "échec du clone de $name (pas de réseau ?), vim marche sans"
	fi
}

chmod +x "$DIR"/bin/*      # scripts 42relink, 42funcs (mis dans le PATH par .zshrc)

section "Liens symboliques"
link "$DIR/zsh/.zshrc"              "$HOME/.zshrc"
link "$DIR/starship/starship.toml"  "$HOME/.config/starship.toml"
link "$DIR/vim/.vimrc"              "$HOME/.vimrc"

section "Plugins vim"
vim_plugin 42header   https://github.com/42Paris/42header.git     # header 42, touche F1
vim_plugin catppuccin https://github.com/catppuccin/vim.git        # thème

# Hook pre-commit (norminette) appliqué aux dépôts créés ou clonés ensuite.
# Les dépôts déjà existants ne sont pas touchés : y lancer `42hook`.
section "Hook norminette"
if command -v git >/dev/null 2>&1; then
	chmod +x "$DIR/git/template/hooks/pre-commit"
	git config --global init.templateDir "$DIR/git/template"
	ok "init.templateDir → hook sur les prochains git init/clone"
fi

# .gitignore global : .o, .a, a.out… ne partent jamais dans un rendu.
# On n'écrase pas un excludesFile déjà configuré ailleurs.
section "Gitignore global"
if command -v git >/dev/null 2>&1; then
	current=$(git config --global core.excludesFile || true)
	if [ -z "$current" ] || [ "$current" = "$DIR/git/ignore" ]; then
		git config --global core.excludesFile "$DIR/git/ignore"
		ok "core.excludesFile → $DIR/git/ignore"
	else
		warn "core.excludesFile déjà réglé sur $current, laissé tel quel"
	fi
fi

section "Terminé"
printf "  Paquets recommandés (si tu as les droits) :\n"
printf "    ${D}Arch  ${R} sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions starship\n"
printf "    ${D}Debian${R} sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting\n"
printf "  Sans sudo (postes 42) : starship s'installe dans ~/.local/bin :\n"
printf "    curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin\n"
printf "  Symboles du prompt : installer une Nerd Font dans le terminal.\n"
printf "  Shell par défaut : chsh -s \$(command -v zsh)\n"
