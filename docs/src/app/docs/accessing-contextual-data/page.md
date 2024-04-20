---
title: Accessing Contextual Data
nextjs:
  metadata:
    title: Accessing Contextual Data
    description: Learn how to access contextual data in your expressions.
---

When evaluating expressions where a context record Id or record was provided, on top of being able to
access the record fields, you can also access the record itself and its Id through special
contextual variables.

## @Id

The `@Id` variable allows you to quickly access the record Id that was provided as a context.

```
@Id # Returns the record Id
```

## @Context

The `@Context` variable allows you to access the record itself.

```
@Context # Returns the record
```

The `@Context` can be used to access the record fields as well. Any fields accessed like this will be
automatically queried just as when referencing fields directly.

```
@Context.Name
```

This syntax is specially useful when combined with functions that allow you to access child information. For example,
let's imagine you are building an object that aggregates information from child and parent accounts. You can use
the `@Context` variable to access the parent account information:

```
MAP(
    ChildAccounts, 
    {
        "name": Name, 
        "parent": @Context.Name, 
        "grandParent": @Context.Parent.Name
    }
)
```
