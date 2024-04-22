---
title: Pricing Table
nextjs:
  metadata:
    title: Pricing Table
    description: Learn about the Pricing Table component.
---

The `Pricing Table` component allows you to display a pricing table. It can be used
to display a list of plans, packages, etc.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Pricing Table](./../../assets/components/pricing-table/pricing-table.png)

## Data Structure

```
{
    tag?: string,
    title: string,
    description?: string,
    plans: [
        {
            name: string,
            price: string,
            action: ButtonAction,
            description?: string,
            features: string[]
        }
    ]
}
```

- `tag` Optional - The tag to display at the top of the component.
- `title` - The title to display.
- `description` Optional - The description to display.
- `plans` - List of plans to display. Each plan should be a map with the following format:
    - `name` - The name of the plan.
    - `price` - The price of the plan.
    - `action` - Action to execute when the plan is selected. Expects the same format as the `Button` component.
    - `description` Optional - The description of the plan.
    - `features` - List of strings detailing the features of the plan.
