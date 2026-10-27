# **************************************************************************** #
#                                                                              #
#                     Template Makefile 42 — à adapter                         #
#                                                                              #
#   À ajuster : NAME, SRCS, et la règle finale ($(AR) pour une lib,            #
#   $(CC) ... -o $(NAME) pour un exécutable).                                  #
#   `make V=1` affiche les commandes complètes au lieu du résumé coloré.       #
#                                                                              #
# **************************************************************************** #

NAME		:= libft.a

CC			:= cc
CFLAGS		:= -Wall -Wextra -Werror
AR			:= ar rcs
RM			:= rm -f

INC_DIR		:= .
SRC_DIR		:= .
OBJ_DIR		:= obj

SRCS		:= ft_strlen.c \
			   ft_strlcpy.c

OBJS		:= $(SRCS:%.c=$(OBJ_DIR)/%.o)
DEPS		:= $(OBJS:.o=.d)

# --- Affichage --------------------------------------------------------------- #
# Q vaut @ (commandes masquées) sauf avec V=1 ; le résumé coloré reste affiché.
Q			:= $(if $(V),,@)
GREEN		:= \033[32m
BLUE		:= \033[34m
MAUVE		:= \033[35m
DIM			:= \033[2m
RESET		:= \033[0m

all: $(NAME)

# Bibliothèque statique. Pour un exécutable, remplacer la ligne $(AR) par :
#   $(Q)$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
$(NAME): $(OBJS)
	$(Q)$(AR) $(NAME) $(OBJS)
	@printf "$(GREEN)✓$(RESET) $(MAUVE)%s$(RESET) prêt\n" "$(NAME)"

# -MMD -MP génèrent les .d : un .o est recompilé si un .h qu'il inclut change.
# Sans ça, modifier un header ne déclenche aucune recompilation.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@printf "$(BLUE)⚙$(RESET) $(DIM)compile$(RESET) %s\n" "$<"
	$(Q)$(CC) $(CFLAGS) -MMD -MP -I$(INC_DIR) -c $< -o $@

clean:
	$(Q)$(RM) -r $(OBJ_DIR)
	@printf "$(DIM)✗ objets supprimés$(RESET)\n"

fclean: clean
	$(Q)$(RM) $(NAME)
	@printf "$(DIM)✗ %s supprimé$(RESET)\n" "$(NAME)"

# Deux sous-make plutôt que `re: fclean all` : make évalue tout son graphe AVANT
# d'exécuter, il croirait donc certains .o encore à jour après le fclean et ne
# les recompilerait pas. Séquencer garantit une reconstruction complète.
re:
	$(Q)$(MAKE) --no-print-directory fclean
	$(Q)$(MAKE) --no-print-directory all

# Inclus en fin de fichier : les .d n'existent pas au premier make, le tiret
# devant include évite l'erreur.
-include $(DEPS)

.PHONY: all clean fclean re
