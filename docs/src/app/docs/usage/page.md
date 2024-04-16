---
title: Usage
nextjs:
  metadata:
    title: Usage
    description: Use Expression from Apex
---

{% callout title="Be aware that" %}
📓Code samples use the `expression` namespace, which assumes you are using the
unlocked package.
If you are not, you can remove the namespace prefix from the code samples.
{% /callout %}

Use `expression.Evaluator` class to evaluate formulas.

```apex
String formula = '1 + 1';
Object result = expression.Evaluator.run(formula);
Assert.areEqual(2, result);
```

You can also evaluate formulas providing an SObject Id as context. This allows you to
make reference to merge fields in the formula and the framework will take care of querying the
correct values.

{% callout %}
📓 One SOQL query is consumed when using this endpoint.
{% /callout %}

```apex
Account account = new Account(Name = 'ACME');
insert account;

Object result = expression.Evaluator.run('Name', account.Id);
Assert.areEqual('ACME', result);
```

Finally, you can use evaluate formulas providing an SObject as context. This can save you a
query if you already have the SObject in memory.

When using this endpoint, the caller is in charge of providing the correct context
with the correct fields being referenced in the formula correctly queried.

```apex
Account account = new Account(Name = 'ACME');
Object result = expression.Evaluator.run('Name', account);
Assert.areEqual('ACME', result);
```

References to related (child or parent) records are also supported.

You can reference parent relationships through dot notation:

```apex
Account parentAccount = new Account(Name = 'ACME');
insert parentAccount;

Account childAccount = new Account(Name = 'ACME Child', ParentId = parentAccount.Id);
insert childAccount;

Object result = expression.Evaluator.run('Parent.Name', childAccount);
Assert.areEqual('ACME', result);
```

You can reference fields on child data in two ways: either referencing the child list directly
to get aggregate data:

```apex
Object result = expression.Evaluator.run('SIZE(ChildAccounts)', parentAccount);
Assert.areEqual(1, result);
```

Or you can use some of the collection functions (like `MAP` or `WHERE`) to extract (or map) data out of the child
records
or filter records. See more information about these functions [here](/docs/functions).

