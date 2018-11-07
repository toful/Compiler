#ifndef types
#define types

typedef enum
{
    NE,
    GE,
    GT,
    LE,
    LT,
    EQ
} relationalOperator;

typedef enum
{
    INTEGER,
    REAL,
    STRING,
    BOOLEAN
} variableType;

typedef struct $
{
    union {
        int intValue;
        float floatValue;
        char * stringValue;
    };
    variableType type;
    char * name;    /*not used*/
    int line;       /*not used*/

} variable;

#endif