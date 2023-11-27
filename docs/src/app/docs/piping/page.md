---
title: Piping
nextjs:
  metadata:
    title: Piping
    description: Data piping support overview.
---

The pipe operator (`->`) allows you to chain operations together. The result of the previous operation
is passed as the first argument to the next operation.

This allows you to "flip" your code, where `a(b)` becomes `b -> a()`.

Why would you use it?

Consider a chain of operations like this:

```apex
WHERE(WHERE([1, 2, 3, 4, 5, 6], $current > 2), $current < 5)
```

This is slightly hard to read, and it's easy to get lost in the parenthesis. With piping, you can
write it like this:

```apex
[1, 2, 3, 4, 5, 6]
    -> WHERE($current > 2)
    -> WHERE($current < 5) 
```

This works when working with record data as well. These 2 are equivalent:

```apex
Evaluator.run('MAP(WHERE(WHERE(ChildAccounts, NumberOfEmployees > 10), AnnualRevenue > 200), Name)', recordId);

Evaluator.run(
    'ChildAccounts ' +
    '-> WHERE(AnnualRevenue > 200) ' +
    '-> WHERE(NumberOfEmployees > 10) ' +
    '-> MAP(Name)', 
    recordId);
```
