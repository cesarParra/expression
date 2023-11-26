---
title: Fetching Record Data
nextjs:
  metadata:
    title: Fetching Record Data
    description: Learn how to fetch record data from the database.
---

A special function, `FETCH`, is provided which allows you to query data from the database. This is useful
when the data you want to use is not provided as part of the context.

The `FETCH` function takes 2 arguments: a string with the `SObjectName` you wish to extract data from,
and a list of strings with the fields you wish to extract. This will query all the records of the given
type and return a list of `SObjects` with the data.

```apex
Object result = expression.Evaluator.run('FETCH("Account", ["Id", "Name"])');
```

This can be combined with other collection functions like `MAP` and `WHERE` to filter or map the data.

```apex
Object result = expression.Evaluator.run('MAP(WHERE(FETCH("Account", ["Id", "Name"]), Name = "ACME"), Id)');
```

Note that when using this function, the automatic context resolution is not performed, so you need to
explicitly specify all fields you wish to reference in the formula.

At this moment, advanced querying capabilities like filtering, sorting, or limiting the number of records
are not supported. To get over these limitations, you can create a custom formula using Apex. See the
[Advanced Usage](#advanced-usage) section for more information.
