---
title: Providing More Context To Your Expressions
nextjs:
  metadata:
    title: Providing More Context To Your Expressions
    description: Learn how to provide more context to your expressions.
---

To perform complex operations where you need to manange additional contextual
information, you can define custom variables that can be used throughout
your expressions. For this, a special function is provided: `LET`.

The `LET` function takes 2 arguments: a map expression which binds
the desired variable name to its value, and the expression to evaluate.

All variables defined by let must be defined as a string key using the `$` prefix.

```
LET(
    {
        "$myVariable": 1, 
        "$myVariable2": 2 
    },
    
    $myVariable + $myVariable2 + 1
    
)
// Output: 4
```
