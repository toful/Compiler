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

typedef struct
{
    int lineNumber;
    void * next;
} lineNumberList;

typedef struct
{
    int lineNumber;
    int caseValue;
    void * next;
} switchLineNumberList;

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
    int id;

    lineNumberList * truelist;
    lineNumberList * falselist;
    lineNumberList * statementlist;
    switchLineNumberList * switchlist;
} variable;


/*
line -> the full content of the three adress code
lineNumber -> the next line of the three adress code that has to be filled
MAXLINES -> constant
temporalNumber -> number id for the next temporal variable
*/
typedef struct
{
        char** line;
        int lineNumber;
        int MAXLINES;
        int temporalNumber;
} addressCode3;

#endif