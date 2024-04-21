---
title: Formula
nextjs:
  metadata:
    title: Formula
    description: Learn about the Formula component.
---

## Formula

The `Formula` component allows you to evaluate an expression and display the result.

## Targets

{% badge text="Lightning Experience" color="pink" /%}

{% badge text="Experience Builder Sites" color="indigo" /%}

When used in a record page, the record Id is automatically used as the context of the expression.

When used in a community page, you can optionally specify the context by setting the `Record Id` property. This can
receive the record Id directly or in the form of a merge field, e.g. `{!recordId}` which will be replaced
with the value of the `recordId` URL parameter.

{% callout %}
Keep in mind that if a record Id is not specified, the expression provided should not contain any merge field
references.
{% /callout %}

### Example

Placing the component in an Account page and using the following formula:

```bash
"Account Name: " + Name + BR(2) + "Rating: " + CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")
```

Results in the following. Note that the component reacts to changes in the record and updates
itself based on the new values when placed in a record page.

![Sample Usage](./../../assets/components/formula/sample-lwc-usage.gif)

### Data Structure

The `Formula` component expects an Expression that evaluates to the following
data structure:

```
string
```

### Properties

- Record Id: The record Id to use as the context of the expression. This can be a merge field, e.g. `{!recordId}`.
  Only
  used when the component is used in a community page.
- Title: The card title.
- Formula Expression: The expression to evaluate.
