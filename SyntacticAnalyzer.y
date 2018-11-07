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

%%

/*grammar definition*/

program : check_mode LINE statement_list

check_mode: LINE check_mode
            | CALC {  mode_calc = 1; 
                    fprintf( yyout, "Compiler set in CALCULATOR Mode\n" );
                    printf( "Compiler set in CALCULATOR Mode\n" ); 
                };
            | PROG {mode_calc = 0; 
                    fprintf( yyout, "Compiler set in PROGRAM Mode\n" );
                    printf( "Compiler set in PROGRAM Mode\n" ); 
                };

statement_list : statement_list statement 
                 | statement

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
    
        if ( sym_lookup( $1.stringValue, &aux ) == SYMTAB_NOT_FOUND || aux.type == $3.type ){
            sym_enter( $1.stringValue, &$3 );
            for( i=0; i < tab; i++ ) printf("\t");
            printf("(%s) %s\n", result_type, $1.stringValue );
            for( i=0; i < tab; i++ ) fprintf(yyout, "\t");
            fprintf( yyout, "(%s) %s\n", result_type, $1.stringValue );
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
        char * result_type = typeToString( $1.type );
        for( i=0; i < tab; i++ ) printf("\t");
        printf("(%s)\n", result_type );

        for( i=0; i < tab; i++ ) fprintf(yyout, "\t");
        fprintf( yyout ,"(%s)\n", result_type );
    }
};

statement : while_statement | if_statement | for_statement | repeat_statement | switch_statement

statement : LINE

while_statement: WHILE init_while level1_boolean_exp_list DO LINE statement_list DONE LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: WHILE statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("While statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout,"\t");
        fprintf(yyout, "While statement done.\n");
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE statement_list FI LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: IF statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("IF statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout,"\t");
        fprintf(yyout, "If statement done.\n");
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE statement_list ELSE init_else LINE statement_list FI LINE 
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: IF ELSE statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("IF ELSE statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout,"\t");
        fprintf(yyout, "IF ELSE statement done.\n");
    }
};


if_statement: IF init_if level1_boolean_exp_list THEN LINE statement_list elseif_statement_list ELSE init_else LINE statement_list FI LINE 
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: ELSIF statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("ELSIF statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout,"\t");
        fprintf(yyout, "ELSIF statement done.\n");
    }
};

elseif_statement_list:  elseif_statement_list elseif_statement
                        | elseif_statement

elseif_statement:   ELSIF init_elsif boolean_expression THEN LINE statement_list

/*for_statement: FOR init_for IDENTIFIER IN range DO LINE statement_list DONE LINE 
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: FOR statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        if ( sym_lookup( $3.stringValue, &aux ) != SYMTAB_NOT_FOUND ){
            sprintf( error_message,"SEMANTIC ERROR: ID ( %s ) is already defined", $3.stringValue);
            yyerror( error_message );
        }
        aux.type = INTEGER;
        sym_enter( $3.stringValue, &aux );
        
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("FOR statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout, "\t");
        fprintf(yyout, "FOR statement done.\n");
    }
};*/

for_statement: FOR init_for IN range DO LINE statement_list DONE LINE 
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: FOR statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("FOR statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout, "\t");
        fprintf(yyout, "FOR statement done.\n");
    }
};

repeat_statement: REPEAT init_repeat LINE statement_list UNTIL level1_boolean_exp_list LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: REPEAT_UNTIL statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab--;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("REPEAT_UNTIL statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout, "\t");
        fprintf(yyout, "REPEAT_UNTIL statement done.\n");
    }
};

range: level1_expression_list RANGE level1_expression_list


switch_statement: SWITCH init_switch level1_expression_list BEGIN_ LINE case_list DEFAULT init_default TWO_POINTS LINE statement_list END LINE
{
    if( mode_calc ){
        sprintf( error_message, "SEMANTIC ERROR: SWITCH statement is not available in the CALCULATOR MODE" );
        yyerror( error_message );
    }
    else{
        tab = tab-2;
        for( i=0; i < tab; i++ ) printf("\t");
        printf("Switch statement done.\n");
        for( i=0; i < tab; i++ ) fprintf(yyout,"\t");
        fprintf(yyout, "Switch statement done.\n");
    }
};

case_list:  case_list case_statemnt
            |case_statemnt

case_statemnt: CASE init_case LITERAL TWO_POINTS  LINE statement_list { tab--; };



init_while: {   printf("\n");
                fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("While statement started\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "While statement started\n");
                tab++; };

init_if: {  printf("\n");
            fprintf(yyout, "\n");
            for( i=0; i < tab; i++ ) printf("\t");
            printf("If statement started\n");
            for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "If statement started\n");
            tab++; };

/*init_for: { for( i=0; i < tab; i++ ) printf("\t");
            printf("\nFor statement started\n");
            for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "\nFor statement started\n");
            tab++; };
*/
init_for: IDENTIFIER { 
            if ( sym_lookup( $1.stringValue, &aux ) != SYMTAB_NOT_FOUND ){
                sprintf( error_message,"SEMANTIC ERROR: ID ( %s ) is already defined", $1.stringValue);
                yyerror( error_message );
            }
            aux.type = INTEGER;
            sym_enter( $1.stringValue, &aux );

            printf("\n");
            fprintf(yyout, "\n");
            for( i=0; i < tab; i++ ) printf("\t");
            printf("For statement started\n");
            for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "For statement started\n");
            tab++; };

init_repeat: {  printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("Repeat_Until statement started\n");
                fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Repeat_Until statement started\n");
                tab++; };

init_else: {for( i=0; i < tab -1; i++ ) printf("\t");
            printf("Else statement\n");
            for( i=0; i < tab -1; i++ ) fprintf( yyout, "\t");
            fprintf( yyout, "Else statement started\n"); };

init_elsif: {   for( i=0; i < tab -1; i++ ) printf("\t");
                printf("Elsif statement\n");
                for( i=0; i < tab -1; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Elsif statement started\n"); };

init_switch: {  printf("\n");
                for( i=0; i < tab; i++ ) printf("\t");
                printf("Switch statement started\n");
                fprintf(yyout, "\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Switch statement started\n");
                tab++; };

init_case: {   for( i=0; i < tab; i++ ) printf("\t");
                printf("Case statement\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Case statement started\n");
                tab++; };

init_default: { for( i=0; i < tab; i++ ) printf("\t");
                printf("Default statement\n");
                for( i=0; i < tab; i++ ) fprintf( yyout, "\t");
                fprintf( yyout, "Default statement started\n");
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
    }
}; 
| level1_expression_list SUBSTRACT level2_expression_list 
{ 
    if( mode_calc ){
        if( sub_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the SUBSTRACT operation" ); 
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
    }
};
| ADD level2_expression_list { $$ = $2; };
| SUBSTRACT level2_expression_list 
{ 
    if( mode_calc ){
        if( change_sign( &$$, $2 ) ) yyerror( "SEMATIC ERROR: something happened in the CAHNGE SIGN operation" );
    }
    else{
        $$ = $2;
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
    }
};
| level2_expression_list DIVIDE level3_expression_list
{ 
    if( mode_calc ){
        if( divide_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DIVIDE operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
    }
};
| level2_expression_list MOD level3_expression_list
{ 
    if( mode_calc ){
        if( mod_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the MOD operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
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
level1_boolean_exp_list :   level1_boolean_exp_list OR level2_boolean_exp_list 
{ 
    if( mode_calc ){
        if( or_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the OR operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
    }
};
| level2_boolean_exp_list { $$ = $1; };


/*                      LEVEL 2 BOOLEAN EXPRESSION LIST                                     */
level2_boolean_exp_list :   level2_boolean_exp_list AND level3_boolean_exp_list
{ 
    if( mode_calc ){
        if( and_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the OR operation" );
    }
    else{
        if( type_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DEF_TYPE operation" );
    }
};
| level3_boolean_exp_list { $$ = $1; };


/*                      LEVEL 3 BOOLEAN EXPRESSION LIST                                     */
level3_boolean_exp_list :   NOT level4_boolean_exp_list
{ 
    if( mode_calc ){
        if( not_op( &$$, $2 ) ) yyerror( "SEMATIC ERROR: something happened in the OR operation" );
    }
    else{
        $$ = $2;
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
    }
};

boolean_expression: TRUE_VALUE { $$.type = BOOLEAN;
                                 $$.intValue = 1; };
                    | FALSE_VALUE { $$.type = BOOLEAN;
                                    $$.intValue = 0; };

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