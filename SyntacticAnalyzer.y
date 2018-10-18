/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                          Syntactic/SemanticAnalyzer
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

%}


%code requires {
  #include "./symtab/types.h"
}

%union {
    variable var;
}

/* declare tokens */
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
%token COMMA
%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token SEPARATOR
%token LINE
%token SQRT

%type <var> expression
%type <var> general_expression
%type <var> level1_expression_list
%type <var> level2_expression_list
%type <var> level3_expression_list
%type <var> level4_expression_list


%%

/*grammar definition*/

program : statement | statement program | LINE program

statement : IDENTIFIER ASSIGN general_expression LINE {
    char * result_type = typeToString( $3.type );
    char * result_value = valueToString( $3 );

    if ( sym_lookup( $1.stringValue, &aux ) == SYMTAB_NOT_FOUND || aux.type == $3.type ){
        sym_enter( $1.stringValue, &$3 );
        printf("ASSIGNATION: id -> %s, type -> %s, value -> %s\n", $1.stringValue, result_type, result_value );
        fprintf( yyout, "ASSIGNATION: id -> %s, type -> %s, value -> %s\n", $1.stringValue, result_type, result_value );
    }
    else{
        sprintf( error_message, "SEMANTIC ERROR: variable ( %s ) type ( %s ) is diferent from the expression type ( %s )", $1.stringValue, typeToString( $1.type ), result_type );
        yyerror( error_message );
        /*fprintf( yyout, "SEMANTIC ERROR: variable ( %s ) type ( %s ) is diferent from the expression type ( %s ), in line %d.\n", $1.stringValue, typeToString( $1.type ), result_type,  yylineno );
        yyerror( "SEMANTIC ERROR: variable type is diferent from the expression type." );*/
    }
};

statement : general_expression LINE {
    char * result_type = typeToString( $1.type );
    char * result_value = valueToString( $1 );

    printf("EXPRESSION: type -> %s, value -> %s\n", result_type, result_value );
    fprintf( yyout ,"EXPRESSION: type -> %s, value -> %s\n", result_type, result_value );
};

statement : { 
    printf("End of the program \n");
}

general_expression : level1_expression_list

level1_expression_list : level1_expression_list ADD level2_expression_list { if( add_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the ADD operation." ); }; 
                        | level1_expression_list SUBSTRACT level2_expression_list { if( sub_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the SUBSTRACT operation." ); };
                        | ADD level2_expression_list { $$ = $2; };
                        | SUBSTRACT level2_expression_list { if( change_sign( &$$, $2 ) ) yyerror( "SEMATIC ERROR: something happened in the CAHNGE SIGN operation." ); };
                        | level2_expression_list { $$ = $1; };


level2_expression_list :    level2_expression_list MULTIPLY level3_expression_list { if( mul_op( &$$, $1, $3) )  yyerror( "SEMATIC ERROR: something happened in the MULTIPLY operation." ); };
                            | level2_expression_list DIVIDE level3_expression_list { if( divide_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the DIVIDE operation." ); };
                            | level2_expression_list MOD level3_expression_list { if( mod_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the MOD operation." ); };
                            | level3_expression_list { $$ = $1; };

level3_expression_list :    level3_expression_list POW level4_expression_list { if( pow_op( &$$, $1, $3) ) yyerror( "SEMATIC ERROR: something happened in the POW operation." ); };
                            | SQRT OPEN_PARENTHESIS level4_expression_list CLOSE_PARENTHESIS { if( sqrt_op( &$$, $3 ) ) yyerror( "SEMATIC ERROR: something happened in the SQUARE operation." ); }; 
                            | level4_expression_list { $$ = $1; };

level4_expression_list :    OPEN_PARENTHESIS expression CLOSE_PARENTHESIS { $$ = $2; }; 
                            | OPEN_BRACKET expression CLOSE_BRACKET { $$ = $2; }; 
                            | expression { $$ = $1; };

expression : level1_expression_list { $$ = $1; };

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