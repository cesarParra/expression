---
title: Misc Operators
nextjs:
  metadata:
    title: Misc Operators
    description: Misc operators overview.
---

- `( )` Parentheses

Groups expressions together.

```apex
expression.Evaluator.run('(1 + 1) * 2'); // 4
```

- `->` Pipe

Read more about piping [here]('./../piping).

```apex
expression.Evaluator.run('[1, 2, 3] -> MAP($current + 1)'); // (2, 3, 4)
```
