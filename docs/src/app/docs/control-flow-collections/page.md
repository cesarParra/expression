---
title: Control Flow Collections
nextjs:
  metadata:
    title: Control Flow Collections
    description: Learn advanced features to build lists and maps
---

## Conditionally add or skip elements when building lists and maps

When building lists and maps, the Expression language allows you to use the special control flow
statement `addif` to conditionally add or skip elements.

```
[addif(true) 1, 2, 3] 
# Results in [1, 2, 3]
```

```
[addif(false) 1, 2, 3]
# Results in [2, 3]
```

This syntax also works with maps:

```
['a': 1, addif(true) 'b': 2, 'c': 3]
# Results in {'a': 1, 'b': 2, 'c': 3}
```

```
['a': 1, addif(false) 'b': 2, 'c': 3]
# Results in {'a': 1, 'c': 3}
```

Let's look at a more complex example. Let's say you want to build a map with contact information,
but only add keys for fields that are not empty:

```
Query(Contact[Name, Email, Phone]) 
    ->  MAP({
        "name": Name,
        addif(NOT(ISBLANK(Email))) "email": Email,
        addif(NOT(ISBLANK(Phone))) "phone": Phone
    })
```
