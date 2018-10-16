#ifndef types
#define types

typedef enum
{
    INTEGER,
    REAL,
    STRING,
} variableType;

typedef struct $
{
    union {
        int intValue;
        float floatValue;
        char * stringValue;
    };
    variableType type;
    char * name;
    int line;

} variable;

#endif