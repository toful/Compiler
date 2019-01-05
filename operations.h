/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                          Operations.h file 
######################################################################*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <math.h>
#include "./symtab/types.h"

int add_op( variable *result, variable x, variable y );
int sub_op( variable *result, variable x, variable y );
int mul_op( variable *result, variable x, variable y );
int divide_op( variable *result, variable x, variable y );
int mod_op( variable *result, variable x, variable y );
int change_sign( variable *result, variable x );
int pow_op( variable *result, variable x, variable y );
int sqrt_op( variable *result, variable x );

int or_op( variable *result, variable x, variable y );
int and_op( variable *result, variable x, variable y );
int not_op( variable *result, variable x );
int relational_op( variable *result, relationalOperator relOp, variable x, variable y );

char * typeToString( variableType type );
char * valueToString( variable x );
char * getValue( variable x );

int type_op( variable *result, variable x, variable y );

char * add_op_symbol( variable *result, variable x, variable y );
char * sub_op_symbol( variable *result, variable x, variable y );
char * mul_op_symbol( variable *result, variable x, variable y );
char * divide_op_symbol( variable *result, variable x, variable y );
char * mod_op_symbol( variable *result, variable x, variable y );
char * change_sign_symbol( variable *result, variable x );
char * pow_op_symbol( variable *result, variable x, variable y );

int get_type_op( variable x, variable y );
char * getRelationalOperatorSymbol( relationalOperator relOp, variableType type );

void write_instruction( char* instruction, variable r, variable x, variable y, char* op );
void write_instruction_short( char* instruction, variable r, variable x, char* op );

