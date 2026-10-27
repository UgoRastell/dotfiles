# dotfiles

Ma config shell et éditeur : **zsh + starship + vim**, orientée cursus 42,
avec un thème commun [Catppuccin Mocha](https://catppuccin.com) sur le prompt, le shell et vim.

```
╭─ ~/42/libft  main ✚1 ?2  13.3  ⏱ 4s ················ 14:32
╰─❯
```

## Installation

```sh
git clone https://github.com/UgoRastell/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Le script crée des liens symboliques (`~/.zshrc`, `~/.config/starship.toml`, `~/.vimrc`) vers ce
dépôt : un `git pull` suffit ensuite pour mettre à jour la config partout. Les fichiers existants
sont sauvegardés en `.bak`. Le dépôt peut être cloné n'importe où, pas seulement dans `~/dotfiles`.

La config est **portable** : plugins et starship sont détectés s'ils sont présents, tout fonctionne
sans (utile sur les postes 42 sans sudo). `~/.local/bin` est ajouté au `PATH`, pour trouver
norminette et starship installés sans droits.

> Les symboles du prompt ( branche,  C) demandent une [Nerd Font](https://www.nerdfonts.com) dans le terminal.

## Contenu

| Fichier | Rôle |
| --- | --- |
| `zsh/.zshrc` | historique partagé, complétion en menu groupée, autosuggestions + coloration syntaxique, pages man en couleur, alias et fonctions 42 |
| `starship/starship.toml` | prompt sur deux lignes : dossier, branche + état git, version de C/Python, durée des commandes, heure |
| `vim/.vimrc` | norme 42 (vraies tabs visibles, colonne 81 marquée, espaces en fin de ligne en rouge), barre de statut colorée, thème catppuccin, plugin 42header |
| `git/template/hooks/pre-commit` | bloque tout commit dont le C n'est pas conforme à la norme |
| `templates/Makefile` | squelette de Makefile 42 (no-relink, dépendances des headers, sortie colorée) |

## Raccourcis

**Shell**

| Commande | Effet |
| --- | --- |
| `ccw` | `cc -Wall -Wextra -Werror` |
| `cr main.c [args]` | compile et exécute d'un coup |
| `norm` | `norminette` |
| `vg ./prog` | valgrind complet (fuites + origine des valeurs non initialisées) |
| `libfttest` | [libftTester](https://github.com/Tripouille/libftTester) : partie obligatoire ; `b` bonus, `a` tout, `split` une fonction |
| `mini` | mini-moulinette, si elle est clonée dans `~/mini-moulinette` |
| `42hook` | installe le hook norminette dans le dépôt courant |
| `42make` | dépose le template de Makefile dans le dossier courant |

**Vim**

| Touche | Effet |
| --- | --- |
| `F1` | insère / met à jour le header 42 |
| `F5` | C : compile avec les flags de la norme et exécute · Python : exécute |
| `F6` | norminette sur le fichier courant |

## Hook norminette

`install.sh` déclare ce dépôt comme `init.templateDir` : tout dépôt **créé ou cloné ensuite** reçoit
automatiquement un hook `pre-commit` qui passe la norminette sur les `.c`/`.h` stagés (renommés
compris) et refuse le commit en cas d'erreur. Il analyse le contenu de l'index, pas celui du disque.

- dépôt déjà existant : lancer `42hook` dedans (marche aussi dans un worktree ou un sous-module)
- commit à forcer malgré une erreur : `git commit --no-verify`
- poste sans norminette : le hook se désactive de lui-même plutôt que de bloquer

## Template Makefile

`42make` dépose `templates/Makefile` dans le dossier courant ; il reste à ajuster `NAME` et `SRCS`.
La sortie est résumée et colorée ; `make V=1` affiche les commandes complètes.

Deux points volontaires : `-MMD -MP` génère les `.d` pour qu'un `.o` soit recompilé quand un header
qu'il inclut change, et `re` enchaîne deux sous-`make` au lieu de `re: fclean all` — make évalue son
graphe avant d'exécuter, il ne recompilerait donc pas les `.o` supprimés entre-temps par `fclean`.
