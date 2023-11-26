---
title: Maps
nextjs:
  metadata:
    title: Maps
    description: Maps support overview.
---

To work with maps, you can use curly braces to create a map:

```apex
Object result = expression.Evaluator.run('{ "a": 1, "b": 2 }'); // { "a": 1, "b": 2 }
```

Keys are allowed to be any value type or even expressions:

```apex
Object result = expression.Evaluator.run('{ 1 + 1: 1, "b": 2 }'); // { 2: 1, "b": 2 }
```

Maps allow you to represent complex data structures, including nested maps and lists:

```apex
Id parentId = '0018N00000IEEK8QAP';
Object result = Evaluator.run(
    '{"Family Name": Name, "Members": { "Count": SIZE(Contacts), "Names": MAP(Contacts, Name)}}',
    parentId
);
// { "Family Name": "Doe", "Members": { "Count": 2, "Names": ["John Doe", "Jane Doe"] } }
```
