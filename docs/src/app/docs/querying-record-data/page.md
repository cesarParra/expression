---
title: Querying Record Data
nextjs:
  metadata:
    title: Querying Record Data
    description: Learn how to query record data from the database.
---

# The Query Function

A special function, `QUERY`, is provided which allows you to query data from the database. This is useful
when the data you want to use is not provided as part of the context.

{% callout %}
Note that not all `Expression` functions can be used within a `QUERY` function. Only the following functions specified throughout
this page are supported, and these are only supported within the `where` filter.
{% /callout %}

The `QUERY` function behaves differently than other functions. Instead of taking a list of arguments, it supports
a special type of syntax that allows you to specify the object type, fields, filters and other query parameters.

```
QUERY(SObjectName(filters)[FIELDS])
```

There are 3 parts to a `QUERY` call:

## `SObjectName`

The name of the object you wish to query. Note that this is not a string literal (it should not be quoted), instead it is a reference to the `SObject` type.

This is the only required part of the query. Only specifying the object name will return all records of that type.

```
QUERY(Account) # Returns all Account records, with only the Id field populated
````

## Filters

After the SObjectName, the query filters can be optionally specified within parentheses. The filters
supported are `where`, `orderBy`, `limit` and `offset`.

### Where

The `where` filter allows you to specify the conditions to filter the results by. Within a `where` filter,
you can use the same operators as in an `Expression`, but they behave slightly differently, as they are used
specifically to build the SOQL query, so they are not evaluated at runtime.

```
QUERY(Account(where: Name = "Acme"))
QUERY(Account(where: Name == "Acme"))
QUERY(Account(where: NumberOfEmployees > 5) [Id, Name, NumberOfEmployees])
QUERY(Account(where: NumberOfEmployees >= 5) [Id, Name, NumberOfEmployees])
...
```

`where` filters also support the `&&` and `||` operators to combine multiple conditions.

```
QUERY(Account(where: Name = "Acme" && NumberOfEmployees > 5))
```

Alternatively, you can also use the `AND` and `OR` functions.

```
QUERY(Account(where: AND(Name = "Acme", NumberOfEmployees > 5)))
```

Besides `AND` and `OR`, other supported functions within a `where` filter are:
* `LIKE`
* `ISIN`
* `ISNOTIN`
* `ISNULL`
* `ISNOTNULL`
* `DATETIMEVALUE`
* `DATEVALUE`
* `DATE`
* `TODAY`
* `NOW`

#### LIKE

The `LIKE` function can be used to perform a partial match. The `LIKE` function takes 2 arguments, the first
is the field to match against, and the second is the value to match. The value can contain the same wildcards supported by a SOQL query (`%`, `_`).

```
QUERY(Account(where: LIKE(Name, "Test 5%")) [Id, Name])
```

#### ISIN and ISNOTIN

The `ISIN` and `ISNOTIN` functions can be used to perform a match against a list of values. Both functions take 2 arguments, the first
is the field to match against, and the second is the list of values to match for or against.

```
QUERY(Account(where: ISIN(Name, ["Test 1", "Test 2"])) [Id, Name])
QUERY(Account(where: ISNOTIN(Name, ["Test 1", "Test 2"])) [Id, Name])
```

#### ISNULL and ISNOTNULL

The `ISNULL` and `ISNOTNULL` functions can be used to perform a match against a null value. Both functions take 1 argument, the field to match against.

```
QUERY(Account(where: ISNULL(Name)) [Id, Name])
QUERY(Account(where: ISNOTNULL(Name)) [Id, Name])
```

### Order By

The `orderBy` filter allows you to specify the field to sort the results by.

```
QUERY(Account(orderBy: Name))
```

An direction can also be specified after the field reference. The direction should either be `ASC` or `DESC`. The default is `ASC`.

```
QUERY(Account(orderBy: Name DESC))
```

You can also order by multiple fields and directions by using a comma separated list (using `[]`) instead of a single field.

```
QUERY(Account(orderBy: [Name DESC, CreatedDate ASC]))
```

### Limit

The `limit` filter allows you to specify the maximum number of records to return.

```
QUERY(Account(limit: 10))
```

### Offset

The `offset` filter allows you to specify the number of records to skip before returning the results.

```
QUERY(Account(offset: 10))
```

## Fields

After the filters, a list of fields can be optionally specified within square brackets. If no fields are specified,
only the `Id` field will be populated.

```
QUERY(Contact[
        Id,
        FirstName
        Account.Name
    ]
)
```

The fields can either be string literals (quoted) or the field references (no quotes).

## Subqueries

Subqueries can be used to query related records. Subqueries are specified by using the `QUERY` function within the field list.

```
QUERY(Account[
        Id,
        Name,
        QUERY(Contacts[Id, FirstName, LastName])
    ]
)
```

Within a subquery, you can also specify any of the filters supported by the `QUERY` function.

## Using variables

Even though a QUERY context only support a subset of the `Expression` functions, you can still use variables within the query.
This allows you to build dynamic queries based on your custom logic.

```
LET(
    {
        "$averageAnnualRevenue": Query(Account[AnnualRevenue]) 
            -> MAP(AnnualRevenue) 
            -> AVERAGE()
    },
    Query(Account(where: AnnualRevenue > $averageAnnualRevenue)[Name]) -> MAP(Name)
)
```
