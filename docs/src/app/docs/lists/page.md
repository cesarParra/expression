---
title: Lists
nextjs:
  metadata:
    title: Lists
    description: List support overview.
---

To work with lists, you have 2 options:

Use square brackets to create a list:

```apex
Object result = expression.Evaluator.run('[1, 2, 3]'); // (1, 2, 3)
```

or use the `LIST` function and pass as many arguments as you want:

```apex
Object result = expression.Evaluator.run('LIST(1, 2, 3)'); // (1, 2, 3)
```
