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

int type_op( variable *result, variable x, variable y );

