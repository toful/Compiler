# Compiler

Simple compiler carried out during the Compilers subject in the URV Computer Science degree.

## Pre-requisites

* [gcc](https://www.gnu.org/software/gcc/) 
* [flex](https://www.gnu.org/software/flex/)
* [bison](https://www.gnu.org/software/bison/)

## Functioning

### Build
```
$ make
```

### Run
```
$ ./compiler INPUT_FILE OUTPUT_FILE
```

You can also put your input files in the input folder and run:
```
$ make run
```

### Clean
```
$ make clean
```

## Documentation

This compiler generates a simple three address code. It works with Integers and Floats and all the iterative and conditional sentences specified below.

### Modes

The compiler has two functioning modes:
* **calc on**: compiler set in the calculator mode.
* **calc off**: compiler set in the program mode.

It has to be indicated in the first line of the input file, so the syntax of the file must be:
```
calc on_or_off
statement list
```

### Allowed Types

* **INTEGER**   ```x := 10```
* **REAL**      ```x := 1.500```
* **STRING**    ```x := "hola"```
* **BOOLEAN**   ```x := true | false```

### Arithmetic Operations

* ```+``` Add
* ```-``` Substract
* ```*``` Multiplication
* ```/``` Division
* ```mod``` Module
* ```**``` Power
* ```sqrt``` Square Root

### Relational Operators
* ```>``` Bigger than
* ```>=``` Bigger or equal than
* ```<``` Less than
* ```<=``` Less or equal than
* ```=``` Equal than
* ```<>``` Different from

### Boolean Operators
* ```not```
* ```and```
* ```or```

### Statements

Statements can be such **arithmetic expressions**:

They are formed by int, float or string literals, identifiers, arithmetic expressions between parenthesis, and the string concatenation operator (+) and the other arithmetic operators (+ , - , * , / , mod, ** , sqrt ) applied over other arithmetic expressions.
The sqrt function is not suported by the compiler mode.

    i * (x + i) - i / 4.0
    17 + (3 * 1.0)
    s + (s + i) + x

**boolean expressions**:

They are formed by boolean literals and identifiers, boolean operators applied over other boolean expressions and relational expressions applied over arithmetic expressions.
Boolean expressions are only suported in conditional and iterative statements in the compiler mode.

    true
    b or not b
    z > 3
    (i > 0 and i <= 10) or false

**assignations** (id := expression):

In an assignation, the identifier type is the same as the expression result type.

    z := i * (x + i) - i / 4.0
    s := "Hola"
    p := "hola" + 5.456
    s := 3 --(4)
    b := z > 3 or not (i > 0 and i <= 10) or false

* If same type arithmetic expression are operated, the result has the same type.
* If integers and reals are arithmeticaly operated, the result has real type.
* If a string is concatenated (+) with a number, the result has string type.
* All the identifiers that apear in an expression, need to be initialized.

**conditional statements**:

If statement syntax:

    if boolean expression then
        statement list
    fi

If else statement syntax:

    if boolean expression then
        statement list
    else
        statement list
    fi

Elsif statement syntax:

    if boolean expression then
        statement list
    elsif boolean expression then
        statement list
    elsif boolean expression then
        statement list
    ...
    else
        statement list
    fi

Switch statement syntax:

    switch arithmetic expression begin
        case LITERAL :
            statement list
        case LITERAL :
            statement list
        ...
        default :
            statement list
    end

or **iterative statements**:

While statement syntax:

    while boolean expression do
        statement list
    done

Repeat Until statement syntax:

    repeat
        statement list
    until boolean expression

For statement syntax:

    for id in range do
        statement list
    done

Do While statement syntax:

    do
        statement list
    while boolean expression

The range is defined as: ```arithmetic expression .. arithmetic expression```

The identifier used in the for statement has to be an uninitialized variable.


### Error treatment

Conditional and iterative statements are not allowed in the calculator mode, so it will be treated as an error.

The following errors have also been considered:
* It is checked that the expressions type is correct before doing any arithmetic operation.
* If an identifier is used in an expression, is checked if it has been initialized.
* When an assignation is carried out, if it was initialized before, it is checked if the identifier and the expression have the same type.

If any of this errors happens, an error message ( with error kind and the line ) will be send and the program will finish.

### Examples
There are some example files in the input folder.

Calculator mode example file:
```
calc on

// assignations
x := 1.5
i := 5
z := i * (x + i) - i / 4.0
b := z > 3 or not (i > 0 and i <= 10) or false
s := "Hello"
// expressions
x
i + i * 2
s + " " + (s + i) + x
b or not b
```

Program mode example file:
```
calc off

// nested sentences
total := 0.0
i := 1
while total < 1000.0 do
    if (i = 1) then
        total := total * 2
    else
        total := total - 1
    fi
    i := -i
done
total

// Fibonacci numbers
n := 50
x := 1
x
y := 1
y
for index in 3..n do
    fib := x + y
    x := y
    y := fib
    fib
done
```
```
calc off

// nested sentences
total := 0.0
i := 1
while total < 1000.0 do
    if (i = 1) then
        total := total * 2
    else
        total := total - 1
    fi
    i := -i
    if total > 666.6 or total = 500.0 then
        i := 1
    fi
done
total
```

## Author

* **Cristòfol Daudén Esmel** - [toful](https://github.com/toful)