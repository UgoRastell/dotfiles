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

### Outils 42 à installer à côté

Sans eux, la config marche quand même : le hook et F7 préviennent qu'ils manquent au lieu de bloquer.

```sh
pip install --user norminette c-formatter-42     # ou : pipx install norminette c-formatter-42
```

Ils s'installent dans `~/.local/bin`, déjà dans le `PATH` grâce au `.zshrc`.

## Comment ça marche

Rien n'est copié : chaque fichier de config de ton HOME est un **lien** vers ce dépôt.
Modifier le dépôt, c'est modifier ta config, et un `git pull` met à jour toutes tes machines d'un coup.

```
  ~/ (ton HOME)                         ~/dotfiles/ (ce dépôt)
  ─────────────                         ──────────────────────
  .zshrc  ─────────── lien ──────────▶  zsh/.zshrc
  .vimrc  ─────────── lien ──────────▶  vim/.vimrc
  .config/starship.toml ── lien ─────▶  starship/starship.toml

  ~/.gitconfig
   ├─ init.templateDir  ─────────────▶  git/template/   (hook copié dans chaque nouveau dépôt)
   └─ core.excludesFile ─────────────▶  git/ignore      (fichiers ignorés partout)

  ~/.vim/pack/dotfiles/start/
   ├─ 42header      (clonés par install.sh)
   └─ catppuccin
```

Qui fait quoi pendant que tu codes :

```
  vim ──F1──▶ header 42        ──F7──▶ code reformaté      ──F6──▶ norminette
   │
   └─ :w ──▶ git add ──▶ git commit ──▶ hook pre-commit ──▶ norminette sur les fichiers stagés
                                             │
                                ✓ OK : commit créé    ✗ erreur : commit refusé, rien n'est perdu
```

## Un projet de A à Z

Exemple avec `push_swap` ; remplace le nom par celui de ton projet.

**1. Créer le projet**

```sh
42new push_swap        # crée ./push_swap/ et t'y place
```

```
  push_swap/
  ├─ Makefile           NAME, SRC_DIR, INC_DIR déjà remplis
  ├─ include/
  │   └─ push_swap.h    garde d'inclusion prête
  ├─ src/
  │   └─ main.c         main minimal, conforme à la norme
  └─ .git/              hook norminette déjà installé
```

Pour une bibliothèque (`libft`), utilise `42new libft.a` : pas de `main.c`, règle `ar` au lieu de l'édition de liens.

**2. Coder dans vim**

- `F1` sur chaque nouveau fichier pour le header 42 (il se met à jour seul à chaque `:w`)
- `F7` pour remettre le fichier à la norme ; il reste à corriger à la main ce que le formateur ne
  sait pas faire (fonction de plus de 25 lignes, plus de 5 variables, plus de 4 paramètres…)
- `F6` pour vérifier avec norminette
- tabs visibles en `│` discret, espaces en fin de ligne en **rouge**, colonne 81 grisée : si ton
  code touche la colonne grise, la ligne est trop longue

**3. Ajouter des fichiers au Makefile**

Chaque nouveau `.c` dans `src/` doit être listé dans `SRCS` (la norme interdit les jokers `*.c`) :

```make
SRCS		:= main.c \
			   parse.c \
			   sort.c
```

**4. Compiler et tester**

```sh
make                   # résumé coloré ; make V=1 pour voir les vraies commandes
make                   # 2e fois : « Nothing to be done » = pas de relink, ce que vérifie l'évaluateur
./push_swap 3 1 2
```

En cas de crash ou de résultat bizarre :

```sh
ccd src/*.c -Iinclude -o debug && ./debug 3 1 2      # sanitizers : affiche la ligne fautive
vg ./push_swap 3 1 2                                  # valgrind : fuites mémoire
```

`ccd` sert seulement à chercher le bug : **jamais** de `-fsanitize` dans le Makefile rendu.

**5. Commiter**

```sh
git add src include Makefile
git commit -m "tri des petites piles"
```

Le hook passe norminette sur ce que tu commites. S'il refuse, il affiche les erreurs ; corrige,
`git add` à nouveau, recommite. Les `.o`, `obj/` et le binaire `push_swap` n'apparaissent pas dans
`git status` : ils sont ignorés automatiquement, inutile de créer un `.gitignore`.

**6. Avant le rendu**

```sh
make fclean && 42relink           # compile proprement et vérifie qu'un 2e make ne refait rien
42funcs read, write, malloc, free # colle ici la liste « fonctions autorisées » du sujet
norminette src include            # tout doit être OK!
git status                        # rien d'oublié, rien en trop
```

`42relink` teste aussi `make bonus` si la règle existe. `42funcs` liste chaque fonction externe
appelée par ton binaire (le `NAME` du Makefile) et marque en rouge celles absentes du sujet.
Une fonction interdite ou un relink, c'est souvent 0 à l'évaluation : ces deux commandes en une
minute évitent la mauvaise surprise.

Pour la `libft`, lance aussi `libfttest` depuis son dossier (`libfttest b` pour les bonus).

## Contenu

| Fichier | Rôle |
| --- | --- |
| `zsh/.zshrc` | historique partagé, complétion en menu groupée, autosuggestions + coloration syntaxique, pages man en couleur, alias et fonctions 42 |
| `starship/starship.toml` | prompt sur deux lignes : dossier, branche + état git, version de C/Python, durée des commandes, heure |
| `vim/.vimrc` | norme 42 (vraies tabs visibles, colonne 81 marquée, espaces en fin de ligne en rouge), barre de statut colorée, thème catppuccin, plugin 42header |
| `git/template/hooks/pre-commit` | bloque tout commit dont le C n'est pas conforme à la norme |
| `git/ignore` | `.gitignore` global : `.o`, `.a`, `a.out`, `obj/`… ne partent jamais dans un rendu |
| `templates/Makefile` | squelette de Makefile 42 (no-relink, dépendances des headers, sortie colorée) |
| `bin/` | scripts ajoutés au `PATH` : `42relink`, `42funcs` (marchent aussi depuis bash) |
| `vscode/` | réglages VS Code (norme 42 limitée au C et aux Makefiles), tâches 42, F7/F8, liste d'extensions installées par `install.sh` |

## Raccourcis

**Shell**

| Commande | Effet |
| --- | --- |
| `42new push_swap` | nouveau projet : `src/main.c`, `include/push_swap.h`, Makefile prérempli, `git init` (`42new libft.a` pour une bibliothèque) |
| `ccw` | `cc -Wall -Wextra -Werror` |
| `ccd` | idem + `-g3 -fsanitize=address,undefined` : debug, pointe la ligne fautive |
| `cr main.c [args]` | compile et exécute d'un coup |
| `norm` | `norminette` |
| `vg ./prog` | valgrind complet (fuites + origine des valeurs non initialisées) |
| `libfttest` | [libftTester](https://github.com/Tripouille/libftTester) : partie obligatoire ; `b` bonus, `a` tout, `split` une fonction |
| `mini` | mini-moulinette, si elle est clonée dans `~/mini-moulinette` |
| `42relink` | lance `make` deux fois (et `make bonus` s'il existe) : ✗ si le 2e passage réécrit un fichier |
| `42funcs [liste]` | fonctions externes appelées par le `NAME` du Makefile ; avec la liste du sujet, ✗ sur les interdites |
| `42hook` | installe le hook norminette dans le dépôt courant |
| `42make` | dépose le template de Makefile dans le dossier courant |

**Vim**

| Touche | Effet |
| --- | --- |
| `F1` | insère / met à jour le header 42 |
| `F5` | C : compile avec les flags de la norme et exécute · Python : exécute |
| `F6` | norminette sur le fichier courant |
| `F7` | reformate le fichier à la norme ([c_formatter_42](https://github.com/dawnbeen/c_formatter_42)) ; le buffer reste intact en cas d'erreur |

**VS Code**

| Touche / action | Effet |
| --- | --- |
| `Ctrl+Alt+H` | insère / met à jour le header 42 (extension 42header ; raccourci retiré à REST Client) |
| `F7` | reformate le fichier C à la norme (c_formatter_42) |
| `F8` | norminette sur le fichier courant |
| `Ctrl+Shift+B` | `make`, erreurs cliquables dans l'onglet Problèmes |
| `Tasks: Run Task` | `make re`, norminette projet, `42relink`, `42funcs`, libftTester |

Les erreurs de norme s'affichent en direct dans le code (extension codam-norminette-3 + Error Lens).
Tabs, colonne 81, espaces de fin supprimés : seulement pour le C et les Makefiles, le reste (JS, Python…) n'est pas touché.

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

## Mettre à jour et modifier

**Récupérer la dernière version** (sur chaque machine) :

```sh
cd ~/dotfiles && git pull && ./install.sh
```

`install.sh` peut être relancé autant de fois que tu veux : il ne refait que ce qui manque.
Ouvre ensuite un nouveau terminal (ou `exec zsh`) pour recharger le shell.

**Changer un réglage** : modifie le fichier dans `~/dotfiles` (par exemple `vim/.vimrc`), c'est
directement ta config qui change. Puis :

```sh
cd ~/dotfiles && git commit -am "ce que j'ai changé" && git push
```

**Sur un poste 42** : clone, lance `install.sh`, c'est tout. Sans sudo, les plugins zsh et starship
sont simplement ignorés ; starship peut s'installer sans droits
(`curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin`).

## Dépannage

| Problème | Cause et solution |
| --- | --- |
| Carrés ou `?` à la place des icônes du prompt | le terminal n'a pas de Nerd Font : en installer une et la choisir dans les réglages du terminal |
| `pre-commit : norminette introuvable` | norminette pas installée : `pip install --user norminette` |
| Le hook ne se lance pas dans un vieux dépôt | il n'est posé que sur les dépôts créés après `install.sh` : lancer `42hook` dedans |
| Besoin de commiter malgré la norme (test, brouillon) | `git commit --no-verify` |
| F7 : `c_formatter_42 introuvable` | `pip install --user c-formatter-42` |
| Vim : couleurs fades | le terminal ne gère pas les vraies couleurs : vim passe sur le thème `habamax`, c'est normal |
| `42hook`/`42make`/`42new` : fichier introuvable | `~/.zshrc` n'est pas un lien vers le dépôt : relancer `install.sh` |
| `42funcs` signale `puts` ou `memset` que tu n'as pas écrits | le compilateur remplace parfois `printf("…\n")` par `puts` ou ajoute `memset` pour initialiser un tableau : retrouver la ligne en cause et la réécrire |
| `42relink` : ✗ alors que le Makefile semble bon | une règle sans fichier cible (souvent `bonus` en `.PHONY` qui relance `ar`) : la faire dépendre de fichiers réels |
| Un `.zshrc` / `.vimrc` d'avant a disparu | il a été sauvegardé en `~/.zshrc.bak` / `~/.vimrc.bak` |
