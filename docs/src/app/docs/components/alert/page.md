---
title: Alert
nextjs:
  metadata:
    title: Alert
    description: Expression Alert Component
---

The `Alert` component can be used to provide information like error messagess, warnings, or success messages to users.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Alert](./../../assets/components/alert/alert.png)

## Data Structure

The `Alert` component expects an Expression that evaluates to the following
data structure:

```
{
    title: string,
    message: string,
    type: 'info' | 'warning' | 'error' | 'success' | 'neutral'
}
```
