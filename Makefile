######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                            Makefile
######################################################################

# General defines
CC = gcc
LEX = flex
YACC = bison
LIB = -lc  -lfl -lm

ELEX = LexicalAnalyzer.l
SRCL = LexicalAnalyzer.c

EYACC = SyntacticAnalyzer.y
SRCY = SyntacticAnalyzer.c

OBJ = LexicalAnalyzer.o SyntacticAnalyzer.o compiler.o
SRC = compiler.c symtab/symtab.c operations.c ThreeAddressCode.c

BIN = compiler

LFLAGS = -n -o $*.c
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g

OTHERS = SyntacticAnalyzer.output SyntacticAnalyzer.h ./output/* ./output
######################################################################
all : 	$(SRCL) $(SRCY)
		$(CC) -o $(BIN) $(CFLAGS) $(SRCL) $(SRCY) $(SRC) $(LIB)

$(SRCL) : 	$(ELEX)
			$(LEX) $(LFLAGS) $<

$(SRCY) : 	$(EYACC)
			$(YACC) $(YFLAGS) $<

clean :
		rm -rf $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS)


run : clean all
	mkdir output
	for filename in ./input/*.txt; do \
		file=$$(basename $$filename); \
		echo "\nRunning "$$filename; \
		./$(BIN) ./input/$$file ./output/$$file; \
	done

test: clean all
	mkdir output
	./$(BIN) ./input/program.txt ./output/program.out;
	more ./output/program.out