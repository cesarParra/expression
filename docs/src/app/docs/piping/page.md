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

```
WHERE(WHERE([1, 2, 3, 4, 5, 6], $current > 2), $current < 5)
```

This is slightly hard to read, and it's easy to get lost in the parenthesis. With piping, you can
write it like this:

```
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

## Capturing Piped Values

By default, piped values are passed as the first argument to the next encountered function. However, you can explicitly
"capture" the piped value, allowing you to use it in any position within the expression to the right-hand
side of the pipe operator.

To capture the piped value, use the `_` keyword. For example:

```
[1, 2, 3, 4, 5, 6]
    -> WHERE(_, $current > 2)  # Here, _ represents the piped value
```

Explicitly capturing the value also allows you to use the same value multiple times:

```
RANGE(1, 10)
    -> WHERE(_, $current > 1)
    -> SUM(_) + SIZE(_)
```
