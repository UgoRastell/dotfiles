# dotfiles

Ma config shell : zsh + starship, orientée cursus 42.

## Installation

```sh
git clone https://github.com/UgoRastell/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Le script crée des liens symboliques (`~/.zshrc`, `~/.config/starship.toml`) vers ce dépôt : un `git pull` suffit ensuite pour mettre à jour la config partout. Les fichiers existants sont sauvegardés en `.bak`.

La config est **portable** : plugins et starship sont détectés s'ils sont présents, tout fonctionne sans (utile sur les postes 42 sans sudo).

## Contenu

- `zsh/.zshrc` — historique partagé, complétion menu, autosuggestions + coloration syntaxique, alias 42 (`ccw`, `norm`, `vg`, fonction `cr`)
- `starship/starship.toml` — prompt : dossier, branche + état git, contexte C, durée des commandes
