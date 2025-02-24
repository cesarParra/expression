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

## Function Parameters

Functions can be declared with any number of parameters, including zero. When called, the number of arguments must match
the number of parameters declared in the function. If the number of arguments does not match the number of parameters,
an error will be thrown.

Function parameters can be of any type, including other functions. The following example shows a function that takes a
function as a parameter and calls it:

```
fun callFunction(f) => f();
```

Parameters can have any name, but they must be unique within the function declaration. These names are local to the
function, but be aware that they will shadow any variables with the same name in the outer scope.

For example, let's consider an Expression that gets called within the context of an Account record. You are able
to reference the Account's name by using the `Name` field. If you declare a function with a parameter named `Name`, it
will shadow the Account's `Name` field, and you will not be able to access it within the function.

```
fun greet(Name) => "Hello, " + Name + "!";

greet("World") # Hello, World!
```

## Considerations

- Names given to functions will superse any of the language's built-in functions. So if you declare a `sum` function,
  the built-in `SUM` function will no longer be available and yours will be used instead.
