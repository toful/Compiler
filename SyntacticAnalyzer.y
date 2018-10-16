%define parse.error verbose
%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>
    #include "./symtab/symtab.h"

    #include "SyntacticAnalyzer.h"
    extern FILE *yyout; 
    extern int yylineno; 
    extern int yylex();
    extern void yyerror( const char* );

    /*capçaleres de les funcions definides*/
    int add_op( variable *result, variable x, variable y );
    int sub_op( variable *result, variable x, variable y );
    int mul_op( variable *result, variable x, variable y );
    int divide_op( variable *result, variable x, variable y );
    int mod_op( variable *result, variable x, variable y );
    int change_sign( variable *result, variable x );
    int pow_op( variable *result, variable x, variable y );
    int sqrt_op( variable *result, variable x );
    char * typeToString( variableType type );
    char * valueToString( variable x );

    variable aux;

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
    /*mirar si el identificador està en la taula de tipus, si ho no està declarar-lo 
    si està, miro si el tipus de l'expressió es correspon al de l'identificador*/
    char * result_type = typeToString( $3.type );
    char * result_value = valueToString( $3 );

    if ( sym_lookup( $1.stringValue, &aux ) == SYMTAB_NOT_FOUND || aux.type == $3.type ){
        sym_enter( $1.stringValue, &$3 );
        printf("ASSIGNATION: id -> %s, type -> %s, value -> %s\n", $1.stringValue, result_type, result_value );
        fprintf( yyout, "ASSIGNATION: id -> %s, type -> %s, value -> %s\n", $1.stringValue, result_type, result_value );
    }
    else{
        fprintf( yyout, "ERROR: variable ( %s ) type ( %s ) is diferent from the expression type ( %s ), in line %d.\n", $1.stringValue, typeToString( $1.type ), result_type,  yylineno );
        yyerror( "ERROR: variable type is diferent from the expression type." );
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

level1_expression_list : level1_expression_list ADD level2_expression_list { if( add_op( &$$, $1, $3) ) yyerror( "ERROR in the ADD operation." ); }; 
                        | level1_expression_list SUBSTRACT level2_expression_list { sub_op( &$$, $1, $3); };
                        | ADD level2_expression_list { $$ = $2; };
                        | SUBSTRACT level2_expression_list { change_sign( &$$, $2 ); };
                        | level2_expression_list { $$ = $1; };


level2_expression_list :    level2_expression_list MULTIPLY level3_expression_list { mul_op( &$$, $1, $3); };
                            | level2_expression_list DIVIDE level3_expression_list { divide_op( &$$, $1, $3); };
                            | level2_expression_list MOD level3_expression_list { mod_op( &$$, $1, $3); };
                            | level3_expression_list { $$ = $1; };

level3_expression_list :    level3_expression_list POW level4_expression_list { pow_op( &$$, $1, $3); };
                            | SQRT OPEN_PARENTHESIS level4_expression_list CLOSE_PARENTHESIS { sqrt_op( &$$, $3 ); }; 
                            | level4_expression_list { $$ = $1; };

level4_expression_list :    OPEN_PARENTHESIS expression CLOSE_PARENTHESIS { $$ = $2; }; 
                            | OPEN_BRACKET expression CLOSE_BRACKET { $$ = $2; }; 
                            | expression { $$ = $1; };

expression : level1_expression_list { $$ = $1; };

expression : LITERAL { $$ = $1; };

expression : IDENTIFIER { 
    if ( sym_lookup( $1.stringValue, &$$ ) == SYMTAB_NOT_FOUND )
        fprintf( yyout ,"ERROR: ID ( %s ) not defined", $1.stringValue);
        yyerror( "ID not defined" );
};


%%

int add_op( variable *result, variable x, variable y ){

    printf("Entering into the add function.\n");

    if( x.type == STRING || y.type == STRING ){
        result->type = STRING;
        
        if( x.type == STRING && y.type == STRING ){
            result->stringValue = (char *) malloc( strlen( x.stringValue ) + strlen( y.stringValue ) + 1 );
            strcpy( result->stringValue, x.stringValue );
            strcat( result->stringValue, y.stringValue );
        }
        else if( x.type == STRING && y.type == INTEGER ){
            result->stringValue = (char *) malloc( strlen( x.stringValue ) + 12 + 1 );
            sprintf( result->stringValue, "%s%d", x.stringValue, y.intValue );
        }
        else if( x.type == INTEGER && y.type == STRING ){
            result->stringValue = (char *) malloc( strlen( y.stringValue ) + 12 + 1 );
            sprintf( result->stringValue, "%d%s", x.intValue, y.stringValue );
        }
        else if( x.type == STRING && y.type == REAL ){
            result->stringValue = (char *) malloc( strlen( x.stringValue ) + 20 + 1 );
            sprintf( result->stringValue, "%s%f", x.stringValue, y.floatValue );
        }
        else if( x.type == REAL && y.type == STRING){
            result->stringValue = (char *) malloc( strlen( y.stringValue ) + 20 + 1 );
            sprintf( result->stringValue, "%f%s", x.floatValue, y.stringValue );
        }
        else return 1; 

        return 0;
    }
    else if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = x.floatValue + y.floatValue;  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = x.floatValue + y.intValue;  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = x.intValue + y.floatValue;  
        }
        else return 1;

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = x.intValue + y.intValue;

        return 0;
    }
    return 1;
}

int sub_op( variable *result, variable x, variable y ){

    printf("Entering into the substract function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = x.floatValue - y.floatValue;  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = x.floatValue - y.intValue;  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = x.intValue - y.floatValue;  
        }
        else yyerror( "ERROR substracting a FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = x.intValue - y.intValue;

        return 0;
    }
    return 1;
}

int mul_op( variable *result, variable x, variable y ){

    printf("Entering into the multiply function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = x.floatValue * y.floatValue;  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = x.floatValue * y.intValue;  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = x.intValue * y.floatValue;  
        }
        else yyerror( "ERROR multiplying a FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = x.intValue * y.intValue;

        return 0;
    }
    return 1;
}

int divide_op( variable *result, variable x, variable y ){

    printf("Entering into the divide function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = x.floatValue / y.floatValue;  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = x.floatValue / y.intValue;  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = x.intValue / y.floatValue;  
        }
        else yyerror( "ERROR dividing a FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = x.intValue / y.intValue;

        return 0;
    }
    return 1;
}

int mod_op( variable *result, variable x, variable y ){

    printf("Entering into the module function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = fmod( x.floatValue, y.floatValue );  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = fmod( x.floatValue, y.intValue );  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = fmod( x.intValue, y.floatValue );  
        }
        else yyerror( "ERROR dividing a FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = x.intValue % y.intValue;

        return 0;
    }
    return 1;
}

int change_sign( variable *result, variable x ){

    printf("Changing the sign of the variable.\n");

    if( x.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = - x.intValue;
    }
    else if ( x.type == REAL ){
        result->type = REAL;
        result->floatValue = - x.floatValue;
    }
    else return 1;

    return 0;
}

int pow_op( variable *result, variable x, variable y ){

    printf("Entering into the pow function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = REAL;

        if( x.type == REAL && y.type == REAL ){
            result->floatValue = pow( x.floatValue, y.floatValue );  
        }
        else if( x.type == REAL && y.type == INTEGER ){
            result->floatValue = pow( x.floatValue, y.intValue );  
        }
        else if( x.type == INTEGER && y.type == REAL ){
            result->floatValue = pow( x.intValue, y.floatValue );  
        }
        else yyerror( "ERROR during the pow operation of FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = pow( x.intValue, y.intValue );

        return 0;
    }
    return 1;
}

int sqrt_op( variable *result, variable x ){

    printf("Sqrt operation.\n");

    if( x.type == INTEGER ){
        result->type = INTEGER;
        result->intValue = sqrt( x.intValue );
    }
    else if ( x.type == REAL ){
        result->type = REAL;
        result->floatValue = sqrt( x.floatValue );
    }
    else return 1;

    return 0;
}

char * typeToString( variableType type ){
    if( type == STRING ){
        return "STRING";
    }
    else if( type == INTEGER ){
        return "INTEGER";
    }
    else if( type == REAL ){
        return "REAL";
    }
    return "";
}

char * valueToString( variable x ){
    char* aux;
    if( x.type == STRING ){
        return x.stringValue;
    }
    else if( x.type == INTEGER ){
        aux = (char *) malloc( 13 );
        sprintf( aux, "%d", x.intValue );
        return aux;
    }
    else if( x.type == REAL ){
        aux = (char *) malloc( 21 );
        sprintf( aux, "%f", x.floatValue );
        return aux;
    }
    return "";
}


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
    fprintf(stderr,"Error: %s ,in line %d \n", explanation, yylineno );
    /*exit( EXIT_FAILURE );*/
}