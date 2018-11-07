/*######################################################################
#                           Compiladors
#                        Cristòfol Daudén Esmel
#                          Operations file 
######################################################################*/

#include "./operations.h"
extern void yyerror( const char* );

/*Arithmetic operations*/

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
        else yyerror( "SEMANTIC ERROR: adding a STRING with something else" ); 

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
        else yyerror( "SEMANTIC ERROR: adding a FLOAT with something else" );

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
        else yyerror( "SEMANTIC ERROR: substracting a FLOAT with something else" );

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
        else yyerror( "SEMANTIC ERROR: multiplying a FLOAT with something else" );

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
        else yyerror( "SEMANTIC ERROR: dividing a FLOAT with something else" );

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
        else yyerror( "SEMANTIC ERROR: in the MOD operation of a FLOAT with something else" );

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
        else yyerror( "SEMANTIC ERROR: during the pow operation of a FLOAT with something else" );

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

/*Logig operations*/
int or_op( variable *result, variable x, variable y ){
    printf("Entering into the OR logical operation function.\n");
    if( x.type == BOOLEAN && y.type == BOOLEAN ){
        result->type = BOOLEAN;
        result->intValue = x.intValue || y.intValue;
        return 0;
    }
    return 1;
}

int and_op( variable *result, variable x, variable y ){
    printf("Entering into the AND logical operation function.\n");
    if( x.type == BOOLEAN && y.type == BOOLEAN ){
        result->type = BOOLEAN;
        result->intValue = x.intValue && y.intValue;
        return 0;
    }
    return 1;
}

int not_op( variable *result, variable x ){
    printf("Entering into the NOT logical operation function.\n");
    if( x.type == BOOLEAN ){
        result->type = BOOLEAN;
        result->intValue = !x.intValue ;
        return 0;
    }
    return 1;
}

int relational_op( variable *result, relationalOperator relOp, variable x, variable y ){
    printf("Entering into the relational operation function.\n");

    if( x.type == REAL || y.type == REAL ){
        result->type = BOOLEAN;

        if( x.type == REAL && y.type == REAL ){
            switch( relOp ){
                case NE:
                    result->intValue = x.floatValue != y.floatValue;
                break;
                case GE:
                    result->intValue = x.floatValue >= y.floatValue;
                break;
                case GT:
                    result->intValue = x.floatValue > y.floatValue;
                break;
                case LE:
                    result->intValue = x.floatValue <= y.floatValue;
                break;
                case LT:
                    result->intValue = x.floatValue < y.floatValue;
                break;
                case EQ:
                    result->intValue = x.floatValue == y.floatValue;
                break;
            }
        }
        else if( x.type == REAL && y.type == INTEGER ){
            switch( relOp ){
                case NE:
                    result->intValue = x.floatValue != y.intValue;
                break;
                case GE:
                    result->intValue = x.floatValue >= y.intValue;
                break;
                case GT:
                    result->intValue = x.floatValue > y.intValue;
                break;
                case LE:
                    result->intValue = x.floatValue <= y.intValue;
                break;
                case LT:
                    result->intValue = x.floatValue < y.intValue;
                break;
                case EQ:
                    result->intValue = x.floatValue == y.intValue;
                break;
            }
        }
        else if( x.type == INTEGER && y.type == REAL ){
            switch( relOp ){
                case NE:
                    result->intValue = x.intValue != y.floatValue;
                break;
                case GE:
                    result->intValue = x.intValue >= y.floatValue;
                break;
                case GT:
                    result->intValue = x.intValue > y.floatValue;
                break;
                case LE:
                    result->intValue = x.intValue <= y.floatValue;
                break;
                case LT:
                    result->intValue = x.intValue < y.floatValue;
                break;
                case EQ:
                    result->intValue = x.intValue == y.floatValue;
                break;
            }
        }
        else yyerror( "SEMANTIC ERROR: substracting a FLOAT with something else" );

        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = BOOLEAN;
        switch( relOp ){
                case NE:
                    result->intValue = x.intValue != y.intValue;
                break;
                case GE:
                    result->intValue = x.intValue >= y.intValue;
                break;
                case GT:
                    result->intValue = x.intValue > y.intValue;
                break;
                case LE:
                    result->intValue = x.intValue <= y.intValue;
                break;
                case LT:
                    result->intValue = x.intValue < y.intValue;
                break;
                case EQ:
                    result->intValue = x.intValue == y.intValue;
                break;
        }

        return 0;
    }
    return 1;
}

/*Auxiliary functions*/

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
    else if( type == BOOLEAN ){
        return "BOOLEAN";
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
    else if( x.type == BOOLEAN ){
        if( x.intValue ) aux = "true";
        else aux = "false";
        return aux;
    }
    return "";
}

/*Auxiliary function, only usefull in the second version of the compiler*/

int type_op( variable *result, variable x, variable y ){
    if( x.type == BOOLEAN || y.type == BOOLEAN ){
        result->type = BOOLEAN;
        return 0;
    }
    if( x.type == STRING || y.type == STRING ){
        result->type = STRING;
        return 0;
    }
    else if( x.type == REAL || y.type == REAL ){
        result->type = REAL;
        return 0;
    }
    else if( x.type == INTEGER && y.type == INTEGER ){
        result->type = INTEGER;
        return 0;
    }
    return 1;
}