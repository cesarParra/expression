---
title: Logical Operators
nextjs:
  metadata:
    title: Logical Operators
    description: Logical operators overview.
---

- `=` and `==` Equal

Evaluates if two values are equal. The `=` and `==` operators are equivalent.

```apex
expression.Evaluator.run('1 = 1'); // true
```

- `<>` and `!=` Not Equal

Evaluates if two values are not equal. The `<>` and `!=` operators are equivalent.

```apex
expression.Evaluator.run('1 <> 2'); // true
```

- `<` Less Than

Evaluates if the first value is less than the second value.

```apex
expression.Evaluator.run('1 < 2'); // true
```

- `>` Greater Than

Evaluates if the first value is greater than the second value.

```apex
expression.Evaluator.run('2 > 1'); // true
```

- `<=` Less Than or Equal

Evaluates if the first value is less than or equal to the second value.

```apex
expression.Evaluator.run('1 <= 1'); // true
```

- `>=` Greater Than or Equal

Evaluates if the first value is greater than or equal to the second value.

```apex
expression.Evaluator.run('1 >= 1'); // true
```

- `&&` Logical AND

Evaluates if both values are true.

```apex
expression.Evaluator.run('true && true'); // true
```

- `||` Logical OR

Evaluates if either value is true.

```apex
expression.Evaluator.run('true || false'); // true
```
