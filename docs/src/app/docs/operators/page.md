---
title: Operators
nextjs:
  metadata:
    title: Operators
    description: Operators overview.
---

## Math Operators

### `+` Addition

```apex
expression.Evaluator.run('1 + 1'); // 2
```

###`-` Subtraction

```apex
expression.Evaluator.run('1 - 1'); // 0
```

### `*` Multiplication

```apex
expression.Evaluator.run('2 * 2'); // 4
```

###`/` Division

```apex
expression.Evaluator.run('4 / 2'); // 2
```

###`^` Exponentiation

```apex
expression.Evaluator.run('2 ^ 2'); // 4
```

## Data Operators

###`( )` Parentheses

Groups expressions together.

```apex
expression.Evaluator.run('(1 + 1) * 2'); // 4
```

###`->` Pipe

Read more about piping [here]('./../piping).

```apex
expression.Evaluator.run('[1, 2, 3] -> MAP($current + 1)'); // (2, 3, 4)
```

## Logical Operators

### Equality

`=` and `==`

Evaluates if two values are equal. The `=` and `==` operators are equivalent.

```apex
expression.Evaluator.run('1 = 1'); // true
```

### Not Equal

`<>` and `!=`

Evaluates if two values are not equal. The `<>` and `!=` operators are equivalent.

```apex
expression.Evaluator.run('1 <> 2'); // true
```

### `<` Less Than

Evaluates if the first value is less than the second value.

```apex
expression.Evaluator.run('1 < 2'); // true
```

### `>` Greater Than

Evaluates if the first value is greater than the second value.

```apex
expression.Evaluator.run('2 > 1'); // true
```

### `<=` Less Than or Equal

Evaluates if the first value is less than or equal to the second value.

```apex
expression.Evaluator.run('1 <= 1'); // true
```

### `>=` Greater Than or Equal

Evaluates if the first value is greater than or equal to the second value.

```apex
expression.Evaluator.run('1 >= 1'); // true
```

### `&&` Logical AND

Evaluates if both values are true.

```apex
expression.Evaluator.run('true && true'); // true
```

### `||` Logical OR

Evaluates if either value is true.

```apex
expression.Evaluator.run('true || false'); // true
```

## String Operators

### Concatenation

`&` and `+`

Concatenates two strings together. The `&` and `+` operators are equivalent.

```apex
expression.Evaluator.run('"Hello" & " " & "World"'); // "Hello World"
```

## List and Map Operators


### `...` Spread Operator

When used within a list, it expands the list into its elements.

```apex
expression.Evaluator.run('LIST(1, 2, 3, ...LIST(4, 5, 6))'); // (1, 2, 3, 4, 5, 6)
expression.Evaluator.run('[1, 2, 3, ...[4, 5, 6]]'); // (1, 2, 3, 4, 5, 6)
```

When using within a map it expands the map into its key-value pairs.

```apex
expression.Evaluator.run('{ "a": 1, "b": 2, ...{ "c": 3, "d": 4 } }'); // { "a": 1, "b": 2, "c": 3, "d": 4 }
```
