---
title: Accessing Contextual Data
nextjs:
  metadata:
    title: Accessing Contextual Data
    description: Learn how to access contextual data in your expressions.
---

When evaluating expressions where a context record Id(s) or record(s) was provided, on top of being able to
access the record's (or records') fields, you can also access the record(s) itself and its Id(s) through special
contextual variables.

## @Id

The `@Id` variable allows you to quickly access the record Id that was provided as a context.

```
@Id # Returns the record Id
```

## @Ids

When the bulk endpoint is used, the `@Ids` variable allows you to access the list of record Ids that were provided as a
context.

```
@Ids # Returns the list of record Ids
```

## @Context

The `@Context` variable allows you to access the record itself when a single Id or record is provided as a context,
or the list of records when multiple Ids or records are provided as a context.

```
@Context # Returns the record or list of records
```

### Single Context Record vs. Multiple Context Records

#### Single Context Record

When the context references a single record, the `@Context` can be used to access the record
fields as well. Any fields accessed like this will be automatically queried just as when referencing fields directly.

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

#### Multiple Context Records

When the context references multiple records, the `@Context` can be used to access the list of records. This is useful
when you want to aggregate information from multiple records.

```
MAP(
    @Context, 
    {
        "name": Name
    }
)
```

Notice from this example that if you want to take advantage of automatic querying for context resolution, you must
always reference `@Context` as the first argument in the collection function. Then you can access the fields of the
records in the collection.

But even though you have to access `@Context` as the first argument, you can still drll down and child relationships
for each record:

```
MAP(
    @Context, 
    MAP(
        ChildAccounts,
        {
            "name": Name, 
            "parent": Parent.Name
        }
    )
)
```
