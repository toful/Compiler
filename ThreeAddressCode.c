/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                          3 Address Code file 
######################################################################*/

#include "./ThreeAddressCode.h"
extern FILE *yyout;


void init_3AC(){
    instructions.MAXLINES = 200;
    instructions.line = (char **) malloc( sizeof( char *) * instructions.MAXLINES );
    instructions.lineNumber = 0;
    instructions.temporalNumber = 1;
}

void emit( char * line ){
    if( instructions.lineNumber == instructions.MAXLINES ){
        instructions.MAXLINES = instructions.MAXLINES + 50;
        instructions.line = realloc( instructions.line, sizeof( char * ) * instructions.MAXLINES );
    }

    int lineSize = strlen(line) + 5;

    char * temp;
    temp = ( char * ) malloc( sizeof(char) * lineSize );
    sprintf( temp, "%d: %s", instructions.lineNumber, line );

    instructions.line[ instructions.lineNumber ] = ( char * ) malloc( sizeof( char ) * lineSize );
    memcpy( instructions.line[ instructions.lineNumber ], temp, lineSize );
    instructions.lineNumber++;
}

void drop( ){
    int i;
    for ( i = 0; i < instructions.lineNumber; ++i )
    {
        fprintf( yyout, "%s\n", instructions.line[i] );
    }
}

int getNextTemporal(){
    int temp = instructions.temporalNumber;
    instructions.temporalNumber++;
    return temp;
}

lineNumberList * createList( int lineNumber ){
    lineNumberList * result = malloc( sizeof(lineNumberList) );
    result->lineNumber = lineNumber;
    result->next = NULL;
    return result;
}

void complete( lineNumberList * line, int pos ){
    if (line == NULL) return;
    /*don't know wht sometimes some lines to complete are not written yet*/
    if( line->lineNumber >= instructions.lineNumber ) return;
    
    char * aux = (char * ) malloc( sizeof(char) * 4 );
    sprintf( aux, "%d", pos );

    int x = 0;
    while( !( instructions.line[ line->lineNumber ][x] == 'G' && instructions.line[ line->lineNumber ][x+1] == 'O' 
             && instructions.line[ line->lineNumber ][x+2] == 'T' && instructions.line[ line->lineNumber ][x+3] == 'O' ) ){
        x++;
    }
    x=x+5;
    int lineSize = strlen( aux );
    instructions.line[ line->lineNumber ] = realloc( instructions.line[ line->lineNumber ], sizeof( char ) * lineSize );
    memcpy( &instructions.line[ line->lineNumber ][x], aux, lineSize );

    free( aux );

    if( line->next != NULL ){
        line = line->next;
        complete( line, pos );
    }

    line = line->next;
}


lineNumberList * merge( lineNumberList * list1, lineNumberList * list2 ){
    if ( list1 == NULL ) return list2;

    lineNumberList * result =  list1;
    while (list1->next != NULL){
        list1 = ( lineNumberList * ) list1->next;
    }
    list1->next = list2;

    return result;
}

switchLineNumberList * createSwitchList( int lineNumber, int caseValue ){
    switchLineNumberList * result = malloc( sizeof(switchLineNumberList) );
    result->lineNumber = lineNumber;
    result->caseValue = caseValue;
    result->next = NULL;
    return result;
}

switchLineNumberList * mergeSwitchList( switchLineNumberList * list1, switchLineNumberList * list2 ){
    if ( list1 == NULL ) return list2;

    switchLineNumberList * result =  list1;
    while (list1->next != NULL){
        list1 = ( switchLineNumberList * ) list1->next;
    }
    list1->next = list2;

    return result;
}