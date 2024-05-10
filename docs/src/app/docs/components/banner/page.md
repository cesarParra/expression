---
title: Banner
nextjs:
  metadata:
    title: Banner
    description: Expression Banner Component
---

The `Banner` component can be used to show marketing messages, promotions, or other important information to users
at the top or bottom of the page.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Banner](./../../assets/components/banner/banner.png)

## Data Structure

The `Banner` component expects an Expression that evaluates a string:

```typescript
string
```

The content can be any valid HTML content.

## Properties

* Sticky Variant: Whether the banner should be sticky or not and where. Options are `top`, `bottom`, or `none`.
* Dismissable: Whether the banner can be dismissed by the user.
