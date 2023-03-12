I_DIR := include
SRC_DIR := src
BIN_DIR := bin

EXE := $(BIN_DIR)/mk
SRC := $(SRC_DIR)/main.c
OBJ := main.o

CC := gcc
INCLUDES = -I$(I_DIR)


.PHONY: all clean

all: $(EXE)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC)

$(EXE): $(OBJ)
	$(CC) $(OBJ) -o $(EXE)
	@$(RM) -r $(OBJ)

clean:
	@$(RM) -r $(BIN_DIR)/mk$(OBJ)
