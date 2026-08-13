# **************************************************************************** #
#                                                                              #
#                     Template Makefile 42 — à adapter                         #
#                                                                              #
#   À ajuster : NAME, SRCS, et la règle finale ($(AR) pour une lib,            #
#   $(CC) ... -o $(NAME) pour un exécutable).                                  #
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

all: $(NAME)

# Bibliothèque statique. Pour un exécutable, remplacer par :
#   $(CC) $(CFLAGS) $(OBJS) -o $(NAME)
$(NAME): $(OBJS)
	$(AR) $(NAME) $(OBJS)

# -MMD -MP génèrent les .d : un .o est recompilé si un .h qu'il inclut change.
# Sans ça, modifier un header ne déclenche aucune recompilation.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MMD -MP -I$(INC_DIR) -c $< -o $@

clean:
	$(RM) -r $(OBJ_DIR)

fclean: clean
	$(RM) $(NAME)

# Deux sous-make plutôt que `re: fclean all` : make évalue tout son graphe AVANT
# d'exécuter, il croirait donc certains .o encore à jour après le fclean et ne
# les recompilerait pas. Séquencer garantit une reconstruction complète.
re:
	$(MAKE) fclean
	$(MAKE) all

# Inclus en fin de fichier : les .d n'existent pas au premier make, le tiret
# devant include évite l'erreur.
-include $(DEPS)

.PHONY: all clean fclean re
