---
title: Declaring Functions
nextjs:
  metadata:
    title: Declaring Functions
    description: Declaring functions support overview.
---

The Expression language allows for custom functions to be declared and used in expressions.
This is useful when you want to encapsulate logic that you would like to use multiple times within an expression,
when you want to make your expressions more readable, or when you want to use a function that is not provided by the
Expression language.

## Declaring Functions

To declare a function, you can use the `fun` keyword followed by the function name, a list of parameters enclosed in
parentheses, and the function body. The function body is a single expression that will be evaluated when the function is
called, and thus will always return a value.

The function declaration must always end with a semicolon (`;`).

For example, the following function takes two parameters and returns the sum of the two parameters:

```
fun add(a, b) => a + b;
```

You can then use this function in an expression like this:

```
add(1, 2); // 3
```

## Scope

Functions have their own scope, but they can also access variables from the outer scope. This means that you can use
variables
declared outside of the function within the function body, or access fields from the context record, if there is one.

For example, given an Expression that runs within an Account record scope, you can reference the Account's `Name` field
within a function:

```
fun greet() => "Hello, " + Name + "!";

greet() # Hello, Account ACME!
```

This also applies for functions that call other functions. The scope of the outer function is available to the inner
function:

```
fun excitedGreeting() => Name + "!";
fun greet(Name) => "Hello, " + excitedGreeting();

greet("Bob") # Hello, Bob!
```

But keep in mind that this can be a little confusing and difficult to read. Preper to always declare
all parameters that the function needs, to make it clear what the function depends on and where the values
are coming from.

## Function Parameters

Functions can be declared with any number of parameters, including zero. When called, the number of arguments must match
the number of parameters declared in the function. If the number of arguments does not match the number of parameters,
an error will be thrown.

Parameters can have any name, but they must be unique within the function declaration. These names are local to the
function, but be aware that they will shadow any variables with the same name in the outer scope.

For example, let's consider an Expression that gets called within the context of an Account record. You are able
to reference the Account's name by using the `Name` field. If you declare a function with a parameter named `Name`, it
will shadow the Account's `Name` field, and you will not be able to access it within the function.

```
fun greet(Name) => "Hello, " + Name + "!";

greet("World") # Hello, World!
```

Function parameters can be of any type, including other functions. The following example shows a function that takes a
function as a parameter and calls it:

```
fun callFunction(f) => f();
```

## Caching

The Expression language will cache the result of a function call, so if a function is called multiple times with the
same
arguments and is within the same context, the result will be cached and the function will not be re-evaluated.

```
fun foo(n) => Query(Account(where: Name = n)[Name]);

[...foo("ACME"), ...foo("ACME")]
```

In this example, the `foo` function will only be evaluated once for the `ACME` account, and the result will be reused
for the second call. This means that a single query will be consumed from the Salesforce limits.

## Considerations

- Names given to functions will superse any of the language's built-in functions. So if you declare a `sum` function,
  the built-in `SUM` function will no longer be available and yours will be used instead.
- Functions can be declared in any order, and they can be called before or after their declaration.
- But they must be declared before the "main" expression to be evaluated.
- Functions can only be declared at the top level of the expression, but not within other functions or expressions, thus
  the following is not valid:

```
# NOT VALID
IF(fun foo() => 5;, 1, 2)
```

- Functions can call each other, even functions declared after the function being called.
- Functions can be called recursively, but be aware of the potential for infinite recursion.

## Examples

### Check if a date is a leap year

```
fun jan1() => DATE(2020, 1, 1);
fun modX(date, x) => MOD(YEAR(date), x);
fun divisibleBy400(date) => modX(date, 400) = 0;
fun divisibleBy4(date) => modX(date, 4) = 0;
fun notDivisibleBy100(date) => modX(date, 100) != 0;

OR(
    divisibleBy400(jan1()),
    divisibleBy4(jan1()) && notDivisibleBy100(jan1())
)
```

### Factorial

```
fun factorial(n) => IF(n = 0 || n = 1, 1, n * factorial(n - 1));

factorial(5)
```

### Custom Sum Array

```
fun sumArray(arr, index) => 
    IF(
        index = SIZE(arr), 
        0, 
        AT(arr, index) + sumArray(arr, index + 1)
    );

sumArray([1, 2, 3], 0)
```
