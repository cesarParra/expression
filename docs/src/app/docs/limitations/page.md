---
title: Limitations
nextjs:
  metadata:
    title: Limitations
    description: Learn about the different limitations of Expression.
---

- When referencing child records, `MAP` only supports one level of relationship,
  so the second argument cannot contain references to children of the child record being mapped.
- When extracting data out of child records through the `MAP` function, any null
  value is skipped. Take this into account when computing information using list
  functions.
