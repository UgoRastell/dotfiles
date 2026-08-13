# dotfiles

Ma config shell et éditeur : zsh + starship + vim, orientée cursus 42.

## Installation

```sh
git clone https://github.com/UgoRastell/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Le script crée des liens symboliques (`~/.zshrc`, `~/.config/starship.toml`, `~/.vimrc`) vers ce dépôt : un `git pull` suffit ensuite pour mettre à jour la config partout. Les fichiers existants sont sauvegardés en `.bak`.

La config est **portable** : plugins et starship sont détectés s'ils sont présents, tout fonctionne sans (utile sur les postes 42 sans sudo).

## Contenu

- `zsh/.zshrc` — historique partagé, complétion menu, autosuggestions + coloration syntaxique, alias 42 (`ccw`, `norm`, `vg`, fonctions `cr`, `42hook`, `42make`)
- `starship/starship.toml` — prompt : dossier, branche + état git, contexte C, durée des commandes
- `vim/.vimrc` — norme 42 (vraies tabs, colonne 80, espaces fin de ligne en rouge), F5 compile/exécute, F6 norminette, plugin 42header cloné automatiquement
- `git/template/hooks/pre-commit` — bloque tout commit dont le C n'est pas conforme à la norme
- `templates/Makefile` — squelette de Makefile 42 (no-relink, dépendances des headers)

## Hook norminette

`install.sh` déclare ce dépôt comme `init.templateDir` : tout dépôt **créé ou cloné ensuite** reçoit
automatiquement un hook `pre-commit` qui passe la norminette sur les `.c`/`.h` stagés et refuse le
commit en cas d'erreur. Il analyse le contenu de l'index, pas celui du disque.

- dépôt déjà existant : lancer `42hook` dedans
- commit à forcer malgré une erreur : `git commit --no-verify`
- poste sans norminette : le hook se désactive de lui-même plutôt que de bloquer

## Template Makefile

`42make` dépose `templates/Makefile` dans le dossier courant ; il reste à ajuster `NAME` et `SRCS`.

Deux points volontaires : `-MMD -MP` génère les `.d` pour qu'un `.o` soit recompilé quand un header
qu'il inclut change, et `re` enchaîne deux sous-`make` au lieu de `re: fclean all` — make évalue son
graphe avant d'exécuter, il ne recompilerait donc pas les `.o` supprimés entre-temps par `fclean`.
