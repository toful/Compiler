/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                        3 Address Code.h file 
######################################################################*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <math.h>
#include "./symtab/types.h"

#define INSTRUCCION_LENGTH 30

addressCode3 instructions;


void init_3AC();
void emit( char * line );
void drop();
int getNextTemporal();
void complete( lineNumberList * line, int pos );
lineNumberList * merge( lineNumberList * list1, lineNumberList * list2 );
lineNumberList * createList( int lineNumber );