---
title: Apex Interoperability
nextjs:
  metadata:
    title: Apex Interoperability
    description: Use formulas in Apex and Apex in formulas.
---

Besides being able to create custom Apex formulas, you can also reference Apex actions to be executed later.
This is useful when the goal is not to retrieve data, but to perform some action. Think about this as having
a reference to a function in Javascript, which you can then execute later.

Note that there is no need to register this class through a Custom Metadata Record
in order to use this functionality.

{% callout type="warning" %}
Only top level classes without namespaces are currently supported.
{% /callout %}

{% callout %}
This is how you can call Apex actions from [Expression Component Buttons](https://github.com/cesarParra/expression#Button).
{% /callout %}

Any class that implements the `expression.IExpressionFunction` interface can be referenced in this way.

```
$Action.Apex.ClassName
````

To pass arguments to your Apex class, you can pass any number of expressions as arguments to the action:

```
$Action.Apex.ClassName(expression1, expression2, ...)
```
