---
title: Anonymous Functions
nextjs:
  metadata:
    title: Anonymous Functions
    description: Anonymous functions support overview.
---

The Expression language also allows you to define anonymous functions.
These are functions that are not named and are defined inline.
They are useful when you need to pass a function as an argument to another function.

```
fun foo(f) => f();

foo(() => 6); // returns 6
```
