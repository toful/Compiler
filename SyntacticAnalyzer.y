/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                     Syntactic/SemanticAnalyzer
######################################################################*/
%define parse.error verbose
%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>
    #include "./symtab/symtab.h"
    #include "operations.h"
    #include "ThreeAddressCode.h"

    #include "SyntacticAnalyzer.h"
    extern FILE *yyout; 
    extern int yylineno;
    extern int yylex();
    extern void yyerror( const char* );

    variable aux;
    char error_message[500];

    int mode_calc;

    int tab=0;
    int i;

    char instruction[ INSTRUCCION_LENGTH ];


%}


%code requires {
  #include "./symtab/types.h"
}

%union {
    variable var;
    relationalOperator rel_op;
}

/* declare tokens */
%token CALC
%token PROG

%token <var> IDENTIFIER 
%token <var> LITERAL
%token ASSIGN
%token POW
%token ADD
%token SUBSTRACT
%token MULTIPLY
%token DIVIDE
%token MOD
%token COMENT
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token SEPARATOR
%token LINE
%token SQRT
%token <rel_op> RELATIONAL_OPERATOR

%token <var> BOOLEAN_IDENTIFIER

%token NOT
%token AND
%token OR
%token TRUE_VALUE
%token FALSE_VALUE

%token IF
%token ELSE
%token FI
%token ELSIF
%token THEN
%token WHILE
%token DO
%token DONE
%token FOR
%token IN
%token REPEAT
%token UNTIL
%token RANGE

%token TWO_POINTS
%token SWITCH
%token BEGIN_
%token CASE
%token END
%token DEFAULT

%type <var> expression
%type <var> general_expression
%type <var> level1_expression_list
%type <var> level2_expression_list
%type <var> level3_expression_list
%type <var> level4_expression_list

%type <var> boolean_expression
%type <var> level1_boolean_exp_list
%type <var> level2_boolean_exp_list
%type <var> level3_boolean_exp_list
%type <var> level4_boolean_exp_list

%type <var> getLine
%type <var> emitGoTo

%type <var> statement_list
%type <var> statement
%type <var> while_statement
%type <var> if_statement
%type <var> for_statement
%type <var> repeat_statement
%type <var> switch_statement
%type <var> LINE

%type <var> conditional_statement

%type <var> P
%type <var> Q

%type <var> elseif_statement
%type <var> elseif_statement_list

%type <var> case_list
%type <var> default_case_list

%type <var> dowhile_statement

%%

/*grammar definition*/

program : check_mode LINE statement_list{
    drop();
};

check_mode: LINE check_mode
            | CALC {  mode_calc = 1; 
                    fprintf( yyout, "Compiler set in CALCULATOR Mode\n" );
                    printf( "Compiler set in CALCULATOR Mode\n" ); 
                };
            | PROG {mode_calc = 0;
                    init_3AC();
                    printf( "Compiler set in PROGRAM Mode\n" ); 
                };

getLine : { $$.line = instructions.lineNumber; };

emitGoTo : { $$.statementlist = createList( instructions.lineNumber );
             sprintf( instruction, "GOTO " );
             emit( instruction );
            };


statement_list : statement_list statement { $$.statementlist = createList( instructions.lineNumber );
                                            $$.truelist = NULL;
                                            $$.falselist = NULL; }
                 | statement { $$.statementlist = createList( instructions.lineNumber );
                               $$.truelist = NULL;
                               $$.falselist = NULL; }

statement : IDENTIFIER ASSIGN general_expression LINE
{
    if( mode_calc ) {
        char * result_type = typeToString( $3.type );
        char * result_value = valueToString( $3 );
    
        if ( sym_lookup( $1.stringValue, &aux ) == SYMTAB_NOT_FOUND || aux.type == $3.type ){
            sym_enter( $1.stringValue, &$3 );
            printf("ASSIGNATION: (%s) %s = %s\n", result_type, $1.stringValue, result_value );
            fprintf( yyout, "ASSIGNATION: (%s) %s = %s\n", result_type, $1.stringValue, result_value );
        }
        else{
            sprintf( error_message, "SEMANTIC ERROR: variable ( %s ) type ( %s ) is diferent from the expression type ( %s )", $1.stringValue, typeToString( $1.type ), result_type );
            yyerror( error_message );
        }
    }
    else{
        char * result_type = typeToString( $3.type );
        char * result_value = valueToString( $3 );
    
        if ( sym_lookup( $1.stringValue, &aux ) == SYMTAB_NOT_FOUND || aux.type == $3.type ){
            if( ! $3.id ){
                $3.id = 1;
                sprintf( instruction, "%s := %s", $1.stringValue, result_value);
                emit( instruction );
            }
            else{
                sprintf( instruction, "%s := %s", $1.stringValue, $3.name );
                emit( instruction );
            }

            $3.name = (char * ) malloc( sizeof( char ) * strlen( $1.stringValue ) );
            memcpy( $3.name, $1.stringValue, strlen( $1.stringValue ) );
            sym_enter( $1.stringValue, &$3 );
        }
        else{
            sprintf( error_message, "SEMANTIC ERROR: variable ( %s ) type ( %s ) is diferent from the expression type ( %s )", $1.stringValue, typeToString( $1.type ), result_type );
            yyerror( error_message );
        }
    }
};

statement : general_expression LINE
{
    if( mode_calc ) {
        char * result_type = typeToString( $1.type );
        char * result_value = valueToString( $1 );

        printf("EXPRESSION: (%s) %s\n", result_type, result_value );
        fprintf( yyout ,"EXPRESSION: (%s) %s\n", result_type, result_value );
    }
    else{
        sprintf( instruction, "PARAM %s", $1.name );
        emit( instruction );

        switch( $1.type ){
            case INTEGER:
                sprintf( instruction, "CALL PUTI,1");
            break;
            case REAL:
                sprintf( instruction, "CALL PUTF,1");
            break;
            default:
                sprintf( instruction, "CALL PUT,1");
            break;
        }
        emit( instruction );

        /*char * result_type = typeToString( $1.type );
        for( i=0; i < tab; i++ ) printf("\t");
        printf("(%s)\n", result_type );*/
    }
};

statement : conditional_statement getLine { complete( $1.statementlist, $2.line ); }

conditional_statement : while_statement | if_statement | for_statement | repeat_statement | switch_statement | dowhile_statement

statement : LINE

while_statement: WHILE init_while getLine level1_boolean_exp_list DO LINE getLine statement_list DONE LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: WHILE statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("While statement done.\n");

        complete( $4.truelist, $7.line );

        /*Useless?
        complete( $8.statementlist, $3.line );*/
        
        sprintf( instruction, "GOTO %d", $3.line );
        emit( instruction );
        
        $$.statementlist = $4.falselist;
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE getLine statement_list FI LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: IF statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("IF statement done.\n");
        
        complete( $3.truelist, $6.line );

        $$.statementlist = merge( $3.falselist, $7.statementlist );
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE getLine statement_list emitGoTo ELSE init_else LINE getLine statement_list FI LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: IF ELSE statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("IF ELSE statement done.\n");

        complete( $3.truelist, $6.line );
        complete( $3.falselist, $12.line );
        $$.statementlist = merge( $7.statementlist, $13.statementlist );
        $$.statementlist = merge( $$.statementlist, $8.statementlist );
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE getLine statement_list emitGoTo getLine elseif_statement_list ELSE init_else LINE statement_list FI LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: ELSIF statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("ELSIF statement done.\n");

        complete( $3.truelist, $6.line );
        complete( $3.falselist, $9.line );
        $$.statementlist = merge( $7.statementlist, $8.statementlist );
        $$.statementlist = merge( $$.statementlist, $10.statementlist );
        $$.statementlist = merge( $$.statementlist, $14.statementlist );
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};

elseif_statement_list:  elseif_statement_list elseif_statement{ $$.statementlist = merge( $1.statementlist, $2.statementlist ); 
                                                                $$.truelist = NULL;
                                                                $$.falselist = NULL;}
                        | elseif_statement

elseif_statement:   ELSIF init_elsif level1_boolean_exp_list THEN LINE getLine statement_list emitGoTo getLine
{
    complete( $3.truelist, $6.line );
    complete( $3.falselist, $9.line );
    $$.statementlist = merge( $7.statementlist, $8.statementlist );
    $$.truelist = NULL;
    $$.falselist = NULL;
}


for_statement: P DO LINE statement_list DONE LINE{
    complete( $1.statementlist, instructions.lineNumber );

    sprintf( instruction, "%s := %s ADDI %d", $1.name, $1.name, 1 );
    emit( instruction );

    sprintf( instruction, "GOTO %d", $1.line );
    emit( instruction );
    $$.statementlist = $1.statementlist;

    tab--;
    for( i=0; i < tab; i++ ) printf("\t");
    printf("FOR statement done.\n");
}

P: Q RANGE level1_expression_list {
    $$.name = $1.name;
    $$.line = instructions.lineNumber;
    sprintf( instruction, "IF %s LEI %s GOTO %d", $1.name, getValue( $3 ), instructions.lineNumber+2 );
    emit( instruction );
    $$.statementlist = createList( instructions.lineNumber );
    sprintf( instruction, "GOTO " );
    emit( instruction );
}

Q: FOR IDENTIFIER IN level1_expression_list {
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: FOR statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }

    printf("\n");
    for( i=0; i < tab; i++ ) printf("\t");
    printf("FOR statement started\n");
    tab++;

    if ( sym_lookup( $2.stringValue, &aux ) != SYMTAB_NOT_FOUND ){
        sprintf( error_message,"SEMANTIC ERROR: ID ( %s ) is already defined", $2.stringValue);
        yyerror( error_message );
    }
    aux.type = INTEGER;
    sym_enter( $2.stringValue, &aux );

    sprintf( instruction, "%s := %s", $2.stringValue, getValue( $4 ) );
    emit( instruction );
    $$.name = $2.stringValue; 
}


repeat_statement: REPEAT init_repeat LINE getLine statement_list UNTIL level1_boolean_exp_list LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: REPEAT_UNTIL statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("REPEAT_UNTIL statement done.\n");

        complete( $7.falselist, $4.line );
        $$.statementlist = $7.truelist;
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};


switch_statement: SWITCH init_switch level1_expression_list emitGoTo BEGIN_ LINE default_case_list END LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: SWITCH statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab = tab-2;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("Switch statement done.\n");

        complete( $4.statementlist, instructions.lineNumber );

        $$.statementlist = $7.statementlist;

        sprintf( instruction, "IF %s EQI %d GOTO %d", getValue( $3 ), $7.switchlist->caseValue, $7.switchlist->lineNumber );
        emit( instruction );
        while( $7.switchlist->next != NULL ){
            $7.switchlist = ( switchLineNumberList * ) $7.switchlist->next;
            sprintf( instruction, "IF %s EQI %d GOTO %d", getValue( $3 ), $7.switchlist->caseValue, $7.switchlist->lineNumber );
            emit( instruction );
        }
        sprintf( instruction, "GOTO %d", $7.line );
        emit( instruction );


    }
};

default_case_list: case_list DEFAULT getLine init_default TWO_POINTS LINE statement_list {
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: SWITCH statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    $$.switchlist = $1.switchlist;
    $$.line = $3.line;
    $$.statementlist = merge( $1.statementlist, $7.statementlist );
    $$.statementlist = merge( $$.statementlist, createList( instructions.lineNumber ) );
    sprintf( instruction, "GOTO " );
    emit( instruction );
}

case_list: case_list CASE init_case LITERAL TWO_POINTS LINE getLine statement_list { 
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: SWITCH statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    tab--;

    $$.statementlist = merge( $8.statementlist, createList( instructions.lineNumber ) );
    $$.statementlist = merge( $$.statementlist, $1.statementlist );
    $$.switchlist = mergeSwitchList( $1.switchlist, createSwitchList( $7.line, $4.intValue ) );
    sprintf( instruction, "GOTO " );
    emit( instruction );
};
| CASE init_case LITERAL TWO_POINTS LINE getLine statement_list { 
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: SWITCH statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    tab--;

    $$.statementlist = merge( $7.statementlist, createList( instructions.lineNumber ) );
    $$.switchlist = createSwitchList( $6.line, $3.intValue );
    sprintf( instruction, "GOTO " );
    emit( instruction );
};

dowhile_statement: DO init_dowhile LINE getLine statement_list WHILE level1_boolean_exp_list LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: DO_WHILE statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("DO_WHILE statement done.\n");

        complete( $7.truelist, $4.line );
        $$.statementlist = $7.falselist;
        $$.truelist = NULL;
        $$.falselist = NULL;
    }
};


init_while: {   printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("While statement started\n");
                /*fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "While statement started\n");*/
                tab++; };

init_if: {  printf("\n");
            for( i=0; i < tab; i++ ) printf("\t");
            printf("If statement started\n");
            /*fprintf(yyout, "\n");
            for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "If statement started\n");*/
            tab++; };

init_repeat: {  printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("Repeat_Until statement started\n");
                /*fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Repeat_Until statement started\n");*/
                tab++; };

init_else: {for( i=0; i < tab -1; i++ ) printf("\t");
            printf("Else statement\n");
            /*for( i=0; i < tab -1; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "Else statement started\n");*/ };

init_elsif: {   for( i=0; i < tab -1; i++ ) printf("\t");
                printf("Elsif statement\n");
                /*for( i=0; i < tab -1; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Elsif statement started\n");*/ };

init_switch: {  printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("Switch statement started\n");
                /*fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Switch statement started\n");*/
                tab++; };

init_case: {   for( i=0; i < tab; i++ ) printf("\t");
                printf("Case statement\n");
                /*for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Case statement started\n");*/
                tab++; };

init_default: { for( i=0; i < tab; i++ ) printf("\t");
                printf("Default statement\n");
                /*for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Default statement started\n");*/
                tab++; };

init_dowhile: {  printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("DO_WHILE statement started\n");
                tab++; };

general_expression :    level1_boolean_exp_list
                        | level1_expression_list


/*                      LEVEL 1 EXPRESSION LIST                                     */
level1_expression_list : level1_expression_list ADD level2_expression_list 
{ 
    if( mode_calc ){
        if( add_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the ADD operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );
        $$.id = 1;

        write_instruction( instruction, $$, $1, $3, add_op_symbol( &$$, $1, $3 ) );
        emit( instruction );
    }
}; 
| level1_expression_list SUBSTRACT level2_expression_list 
{ 
    if( mode_calc ){
        if( sub_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the SUBSTRACT operation" ); 
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );
        $$.id = 1;
        
        write_instruction( instruction, $$, $1, $3, sub_op_symbol( &$$, $1, $3 ) );
        emit( instruction );
    }
};
| ADD level2_expression_list { $$ = $2; };
| SUBSTRACT level2_expression_list 
{ 
    if( mode_calc ){
        if( change_sign( &$$, $2 ) ) yyerror( "SEMATIC ERROR: something happened in the CAHNGE SIGN operation" );
    }
    else{
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );

        write_instruction_short( instruction, $$, $2, change_sign_symbol( &$$, $2 ) );
        emit( instruction );
    } 
};
| level2_expression_list { $$ = $1; };


/*                      LEVEL 2 EXPRESSION LIST                                     */
level2_expression_list : level2_expression_list MULTIPLY level3_expression_list
{ 
    if( mode_calc ){
        if( mul_op( &$$, $1, $3) )  yyerror( "SEMATIC ERROR: something happened in the MULTIPLY operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );
        $$.id = 1;

        write_instruction( instruction, $$, $1, $3, mul_op_symbol( &$$, $1, $3 ) );
        emit( instruction );
    }
};
| level2_expression_list DIVIDE level3_expression_list
{ 
    if( mode_calc ){
        if( divide_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DIVIDE operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );
        $$.id = 1;

        write_instruction( instruction, $$, $1, $3, divide_op_symbol( &$$, $1, $3 ) );
        emit(instruction);
    }
};
| level2_expression_list MOD level3_expression_list
{ 
    if( mode_calc ){
        if( mod_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the MOD operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        $$.name = ( char * ) malloc( sizeof( char ) * 4 );
        sprintf( $$.name, "$t%02d", getNextTemporal() );
        $$.id = 1;

        write_instruction( instruction, $$, $1, $3, mod_op_symbol( &$$, $1, $3 ) );
        emit( instruction );
    }
};
| level3_expression_list { $$ = $1; };


/*                      LEVEL 3 EXPRESSION LIST                                     */
level3_expression_list : level3_expression_list POW level4_expression_list
{ 
    if( mode_calc ){
        if( pow_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the POW operation" ); 
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
    }
};
| SQRT OPEN_PARENTHESIS level4_expression_list CLOSE_PARENTHESIS 
{ 
    if( mode_calc ){
        if( sqrt_op( &$$, $3 ) ) yyerror( "SEMATIC ERROR: something happened in the SQUARE operation" );
    }
    else{
        $$ = $3;
    }
}; 
| level4_expression_list { $$ = $1; };


/*                      LEVEL 4 EXPRESSION LIST                                     */
level4_expression_list :    OPEN_PARENTHESIS level1_expression_list CLOSE_PARENTHESIS 
{
    if( mode_calc ){
        $$ = $2;
    }
    else{
        $$ = $2;
    }
};
| expression { $$ = $1; };



/*                      LEVEL 1 BOOLEAN EXPRESSION LIST                                     */
level1_boolean_exp_list :   level1_boolean_exp_list OR getLine level2_boolean_exp_list 
{ 
    if( mode_calc ){
        if( or_op( &$$, $1, $4) ) yyerror( "SEMATIC ERROR: something happened in the OR operation" );
    }
    else{
        if( type_op( &$$, $1, $4) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );

        complete( $1.falselist, $3.line );
        $$.truelist = merge( $1.truelist, $4.truelist );
        $$.falselist = $4.falselist;
    }
};
| level2_boolean_exp_list { $$ = $1; };


/*                      LEVEL 2 BOOLEAN EXPRESSION LIST                                     */
level2_boolean_exp_list :   level2_boolean_exp_list AND getLine level3_boolean_exp_list
{ 
    if( mode_calc ){
        if( and_op( &$$, $1, $4) ) yyerror( "SEMATIC ERROR: something happened in the AND operation" );
    }
    else{
        if( type_op( &$$, $1, $4) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
        complete( $1.truelist, $3.line );
        $$.truelist = $4.truelist;
        $$.falselist = merge( $1.falselist, $4.falselist );
    }
};
| level3_boolean_exp_list { $$ = $1; };


/*                      LEVEL 3 BOOLEAN EXPRESSION LIST                                     */
level3_boolean_exp_list :   NOT level4_boolean_exp_list
{ 
    if( mode_calc ){
        if( not_op( &$$, $2 ) ) yyerror( "SEMATIC ERROR: something happened in the NOT operation" );
    }
    else{
        $$ = $2;

        $$.truelist = $2.falselist;
        $$.falselist = $2.truelist;
    }
};
| level4_boolean_exp_list { $$ = $1; };


/*                      LEVEL 4 BOOLEAN EXPRESSION LIST                                     */
level4_boolean_exp_list :   OPEN_PARENTHESIS level1_boolean_exp_list CLOSE_PARENTHESIS 
{
    if( mode_calc ){
        $$ = $2;
    }
    else{
        $$ = $2;
    }
};
| boolean_expression { $$ = $1; };


/*                      BOOLEAN EXPRESSION                                                       */
boolean_expression: level1_expression_list RELATIONAL_OPERATOR level1_expression_list
{
    if( mode_calc ){
        if( relational_op( &$$, $2, $1, $3 ) ) yyerror( "SEMATIC ERROR: something happened in the RELATIONAL OPERATION function" );
    }
    else{
        $$.type = BOOLEAN;

        $$.truelist = createList( instructions.lineNumber );
        $$.statementlist = NULL;
        sprintf( instruction, "IF %s %s %s GOTO ", getValue( $1 ), getRelationalOperatorSymbol( $2, get_type_op( $1 , $3 ) ), getValue( $3 ) );
        emit( instruction );
        $$.falselist = createList( instructions.lineNumber );
        sprintf( instruction, "GOTO " );
        emit( instruction );
    }
};

boolean_expression: TRUE_VALUE { $$.type = BOOLEAN;
                                 $$.intValue = 1; 
                                 if( !mode_calc ){
                                     $$.truelist = createList( instructions.lineNumber );
                                     $$.falselist = NULL;
                                     $$.statementlist = NULL;
                                     sprintf( instruction, "GOTO " );
                                     emit( instruction );
                                 }};
                    | FALSE_VALUE { $$.type = BOOLEAN;
                                    $$.intValue = 0;
                                    if( !mode_calc ){
                                        $$.falselist = createList( instructions.lineNumber );
                                        $$.truelist = NULL;
                                        $$.statementlist = NULL;
                                        sprintf( instruction, "GOTO " );
                                        emit( instruction );
                                    }};

boolean_expression: BOOLEAN_IDENTIFIER {
    if ( sym_lookup( $1.stringValue, &$$ ) == SYMTAB_NOT_FOUND ){
        sprintf( error_message,"SEMANTIC ERROR: ID ( %s ) not defined", $1.stringValue);
        yyerror( error_message );
    }
    if ( $$.type != BOOLEAN ) {
        sprintf( error_message,"SEMANTIC ERROR: something diferent from a BOOLEAN given in a boolean expression");
        yyerror( error_message );
    }
}

/*                      ARITHMETIC EXPRESSION                                                       */

expression : LITERAL { $$ = $1; };

expression : IDENTIFIER { 
    if ( sym_lookup( $1.stringValue, &$$ ) == SYMTAB_NOT_FOUND ){
        sprintf( error_message,"SEMANTIC ERROR: ID ( %s ) not defined", $1.stringValue);
        yyerror( error_message );
    }
};


%%


int init_syntactic_analysis(char * filename){
    int error = EXIT_SUCCESS;
    yyout = fopen( filename,"w" );
    if (yyout == NULL) {error = EXIT_FAILURE;} 
    return error;
}

int semantic_analysis(){
    int error; 
    if ( yyparse() == 0 ){ error =  EXIT_SUCCESS; }
    else { error =  EXIT_FAILURE; } 
    return error;
}

int end_syntactic_analysis(){
    int error; 
    error = fclose(yyout); 
    if( error == 0 ){ error = EXIT_SUCCESS; }
    else{ error = EXIT_FAILURE; } 
    return error;
}

void yyerror(const char *explanation){
    fprintf(stderr, "%s, in line %d \n", explanation, yylineno );
    fprintf(yyout, "%s, in line %d \n", explanation, yylineno );
    exit( EXIT_FAILURE );
}