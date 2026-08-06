#!/bin/sh
# Installe les dotfiles par liens symboliques.
# Usage : git clone https://github.com/UgoRastell/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
	src="$1"; dst="$2"
	mkdir -p "$(dirname "$dst")"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		mv "$dst" "$dst.bak"
		echo "→ $dst existant sauvegardé en $dst.bak"
	fi
	ln -sf "$src" "$dst"
	echo "✓ $dst → $src"
}

link "$DIR/zsh/.zshrc"              "$HOME/.zshrc"
link "$DIR/starship/starship.toml"  "$HOME/.config/starship.toml"

echo ""
echo "Terminé. Paquets recommandés (si tu as les droits) :"
echo "  Arch   : sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions starship"
echo "  Debian : sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting && curl -sS https://starship.rs/install.sh | sh"
echo "Sans sudo (postes 42) : la config marche quand même, les plugins/starship sont juste ignorés."
echo "Shell par défaut : chsh -s \$(command -v zsh)"
