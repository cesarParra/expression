---
title: String Interpolation
nextjs:
  metadata:
    title: String Interpolation
    description: String interpolation support overview.
---

You can access the value of an expression inside a string by using ${expression}. This is useful
when you want to build complex strings that include the result of an expression or when concatenating
multiple strings together without having to use the `&` or `+` operators.

```apex
String expression = 'LET({"$greeting": "World"}, "${ $greeting } World!")';
expressionEvaluator.run(expression); // "World World!"
````
