---
title: Configuring the evaluation
nextjs:
  metadata:
    title: Configuring the evaluation
    description: Learn about the different configuration options available for the evaluation.
---

All endpoints also accept a configuration (`expression.Configuration`) object as the last argument. This object
allows you to provide the following to the evaluator:

* `sharing` - The sharing mode to use when querying data. See [Considerations](./../docs/considerations) for more information.
* `printAst` - Whether to print the AST (Abstract Syntax Tree) of the expression being evaluated. Useful for debugging.
* `customContext` - A map of custom variables to be used in the expression.
  Anything provided through here will prefixed with an `@` symbol and will be available globally in the expression.
  Notice this is different from using the `LET` function to define variables,
  as those are only available within the expression they are defined in.
