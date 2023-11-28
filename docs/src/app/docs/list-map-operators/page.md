---
title: List and Map Operators
nextjs:
  metadata:
    title: List and Map Operators
    description: List and Map operators overview.
---

- `...` Spread Operator

When used within a list, it expands the list into its elements.

```apex
expression.Evaluator.run('LIST(1, 2, 3, ...LIST(4, 5, 6))'); // (1, 2, 3, 4, 5, 6)
expression.Evaluator.run('[1, 2, 3, ...[4, 5, 6]]'); // (1, 2, 3, 4, 5, 6)
```

When using within a map it expands the map into its key-value pairs.

```apex
expression.Evaluator.run('{ "a": 1, "b": 2, ...{ "c": 3, "d": 4 } }'); // { "a": 1, "b": 2, "c": 3, "d": 4 }
```
