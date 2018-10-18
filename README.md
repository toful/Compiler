# Compiler

Simple compiler carried out during the Compilers subject in the URV Computer Science degree.
This first version generates a simple calculator that can do some simple operations

## Pre-requisites

* [gcc](https://www.gnu.org/software/gcc/) 
* [flex](https://www.gnu.org/software/flex/)
* [bison](https://www.gnu.org/software/bison/)

## Working with the compiler

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
##Documentation

###Types

* **INTEGERS**   ```x := 10```
* **REALS**      ```x := 1.500```
* **STRINGS**    ```x := "hola"```

###Operations

* ```+``` Add
* ```-``` Substract
* ```*``` Multiplication
* ```/``` Division
* ```mod``` Module
* ```**``` Power
* ```sqrt``` Square Root


###Sentences

Sentences can be such **arithmetic expressions**:
    They be formed by int, float or string literals, identifiers, parenthesis, the string concatenation operator (+), and the other arithmetic operators. 
    ```
    i * (x + i) - i / 4.0
    17 + (3 * 1.0)
    s + (s + i) + x 
    ```
or **assignations** (id := expression):
    In an assignation, the identifier type is the same as the expression result type.
    ```
    z := i * (x + i) - i / 4.0
    s := "Hola"
    p := "hola" + 5.456
    s := 3 --(4)
    ```

* If same type arithmetic expression are operated, the result has the same type.
* If integers and reals are arithmeticaly operated, the result has real type.
* If a string is concatenated (+) with a number, the result has string type.
* All the identifiers that apear in an expression, need to be initialized.

###Error treatment

It have beed considered the following errors:
* It is checked that the expressions type is correct before doing any arithmetic operation.
* If an identifier is used in an expression, is checked if it has been initialized.
* When an assignation is carried out, if it was initialized before, it is checked if the identifier and the expression have the same type.

If any of this errors happen, an error message ( with error kind and the line ) will be send and the program will finish.

###Example

Here there is an example file:
```
x := 1.5
i := 5
z := i * (x + i) - i / 4.0
s := "Hola"
// un comentari
x
i
z
s
17 + (3 * 1.0)

/*
* cometari multilinea
*/

i + i * 2
s + (s + i) + x
```

## Author

* **Cristòfol Daudén Esmel** - [toful](https://github.com/toful)