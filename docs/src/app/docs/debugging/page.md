---
title: Debugging
nextjs:
  metadata:
    title: Debugging
    description: Learn how to debug your Expressions.
---

The Expression Playground provides a few tools to help you debug your Expressions.

## Results

The Results tab allows you to see the output of your Expression. Since all Expressions return
a value, when evaluating an Expression, the result will always be displayed in the Results tab.

![Result Tab](./../result-tab.png)

## Printing Data

At any point in your Expression, you can use the special `PRINT` function to log data to the Result console. This can be
useful
when debugging complex expressions where you want to understand the shape of the data at different points.

The `PRINT` function takes one argument and returns it as-is. This allows you to insert it into your Expression without
affecting the result.

```
PRINT(1 + 2)
```

In the following example, we print after each step of a complex calculation:

```
Query(Contact[Name, Email, Phone]) 
    -> PRINT()
    ->  MAP({
        "name": Name,
        addif(NOT(ISBLANK(Email))) "email": Email,
        addif(NOT(ISBLANK(Phone))) "phone": Phone
    })
    -> PRINT()
    -> SIZE()
```

![Print](./../playground-print.png)

Notice how the Result console shows each output, with a label of "printed" to separate printed
values from the final result.

## Errors

When there is an error in your Expression syntax, or an error occurs while evaluating the Expression,
the source of the error will have a red underline in the editor. The Results tab will also display the error message.

![Playground With Error](./../playground-with-error.png)
