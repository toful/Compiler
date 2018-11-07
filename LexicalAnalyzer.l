/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                          LexicalAnalyzer
######################################################################*/
%option yylineno
%option noyywrap

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	#include "./SyntacticAnalyzer.h"
    #include "./symtab/symtab.h"
    #include "./symtab/types.h"

    extern FILE *yyin;

    variable aux;

%}

INTEGER     0|"-"[1-9][0-9]*|[1-9][0-9]*
REAL        {INTEGER}"."[0-9][0-9]*

DIGIT       [0-9]
LETTER		[a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*

LINE        "\n"

STRING      "\""[^"\""{LINE}]*"\""

COMENT      "/*"(.|{LINE})*"*/"|"//".*{LINE}

OPEN_PARENTHESIS	   "("
CLOSE_PARENTHESIS	   ")"

TAB         "\t"
SPACE       " "
OPEN_BRACKET           "{"
CLOSE_BRACKET          "}"
COMMA 		","
SEPARATOR	";"
TWO_POINTS  ":"

%%

"calc on"           { return CALC; }
"calc off"          { return PROG; }

"<>"                {   yylval.rel_op = NE; 
                        /*printf("<>");*/
                        return RELATIONAL_OPERATOR; }

">="                {   /*printf(">=");*/
                        yylval.rel_op = GE; 
                        return RELATIONAL_OPERATOR; }

">"                 {   /*printf(">");*/
                        yylval.rel_op = GT; 
                        return RELATIONAL_OPERATOR; }

"<="                {   /*printf("<=");*/
                        yylval.rel_op = LE; 
                        return RELATIONAL_OPERATOR; }

"<"                 {   /*printf("<");*/
                        yylval.rel_op = LT; 
                        return RELATIONAL_OPERATOR; }

"="                 {   /*printf("=");*/
                        yylval.rel_op = EQ; 
                        return RELATIONAL_OPERATOR; }

"not"               { /*printf(" not ");*/ return NOT; }
"and"               { /*printf(" and ");*/ return AND; }
"or"                { /*printf(" or ");*/ return OR; }

"true"              { /*printf("true");*/ return TRUE_VALUE; }
"false"             { /*printf("false");*/ return FALSE_VALUE; }

"if"                { return IF; }
"else"              { return ELSE; }
"fi"                { return FI; }
"elsif"             { return ELSIF; }
"then"              { return THEN; }
"while"             { return WHILE; }
"do"                { return DO; }
"done"              { return DONE; }
"for"               { return FOR; }
"in"                { return IN; }
"repeat"            { return REPEAT; }
"until"             { return UNTIL; }
"\.\."              { return RANGE; }

"switch"            { return SWITCH; }
"begin"             { return BEGIN_; }
"case"              { return CASE; }
"end"               { return END; }
"default"           { return DEFAULT;}


":="                { return ASSIGN; }

"**"                { return POW; }
"+"                 { return ADD; }
"-"                 { return SUBSTRACT; }
"*"                 { return MULTIPLY; }
"/"                 { return DIVIDE; }
"mod"               { return MOD; }
"sqrt"              { return SQRT; }

{IDENTIFIER}        {   yylval.var.stringValue = (char *) malloc( sizeof( char ) * yyleng );
                        memcpy( yylval.var.stringValue, yytext, yyleng );
                        yylval.var.line = yylineno;
                        /*printf( "%s", yylval.var.stringValue );*/
                        if ( sym_lookup( yylval.var.stringValue, &aux ) != SYMTAB_NOT_FOUND ){
                            if( aux.type == BOOLEAN ) return BOOLEAN_IDENTIFIER;
                        }
                        return IDENTIFIER; } 

{INTEGER}           {   yylval.var.intValue = atoi(yytext);
                        yylval.var.type = INTEGER;
                        /*printf( "%d", yylval.var.intValue );*/
                        return LITERAL; }

{REAL}              {   yylval.var.floatValue = atof(yytext); 
                        yylval.var.type = REAL;
                        /*printf( "%f", yylval.var.floatValue );*/
                        return LITERAL; }

{STRING}            {   yylval.var.stringValue = (char *) malloc( sizeof( char ) * yyleng -2 );
                        memcpy( yylval.var.stringValue, &(yytext[1]), yyleng -2 );
                        yylval.var.type = STRING;
                        /*printf( "%s", yylval.var.stringValue );*/
                        return LITERAL; }

{COMENT}            { }

{OPEN_BRACKET}      { return OPEN_BRACKET; }

{CLOSE_BRACKET}     { return CLOSE_BRACKET;}

{COMMA}             {  }
{OPEN_PARENTHESIS}  { /*printf("(");*/ return OPEN_PARENTHESIS; }
{CLOSE_PARENTHESIS} { /*printf(")");*/ return CLOSE_PARENTHESIS; }
{SEPARATOR}         { return SEPARATOR; }

{TWO_POINTS}        { return TWO_POINTS; }

{LINE}              { return LINE; }

<<EOF>>             {   static int end = 0; 
                        return end++ ? 0 : LINE;
                    }

{SPACE}             {}



%%

int init_lexic_analysis ( char * file_name ){
    int error; 
    yyin = fopen( file_name, "r" );
    if ( yyin == NULL ) {
         error = EXIT_FAILURE; 
    }
    else { 
        error = EXIT_SUCCESS; 
    }
    return error;
}

int end_lexic_analysis () {
    int error;
    error = fclose( yyin );
    if (error == 0) {
        error = EXIT_SUCCESS;
    }
    else { 
        error = EXIT_FAILURE;
    }
    return error;
}


/*yyleng emmagatzema el nombre de caracters de la cadena emmagatzemada a yytext

ymore(): impedeix l’accio per defecte de buidar el contingut de yytext, de manera que el lexema seguent identificat a partir
 del flux d’entrada es col·loca a continuacio de la variable yytext
.
yyless(n): modifica el nombre de caracters que ens retorna yytext, es a dir, del lexema identificat nomes ens quedem amb els
n caracters primers. La resta de caracters perduren a la memoria intermedia per serprocessat posteriorment.

input(): retorna el seguent caracter de l’entrada estandard.

output(c): escriu el caracter c a la sortida

unput(c): posa el caracter c a la memoria intermedia d’entrada de manera que aquest sigui el seguent caracter que llegira
la funcio input().
*/

/*El problema d'aquesta definició de String ( "\"".*"\"" )és que "hola" + "adios" m'ho agafa com un únic string*/
