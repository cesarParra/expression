---
title: Stats
nextjs:
  metadata:
    title: Stats
    description: Learn about the Stats component.
---

The `Stats` component allows you to display a list of stats. It can be used
to display a list of metrics, KPIs, etc.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Stats](./../../assets/components/stats/stats.png)

## Data Structure

```
{
    title: string,
    description?: string,
    stats: [
        {
            label: string,
            value: string
        }
    ]
}
```

- `title` - The title to display.
- `description` Optional - The description to display.
- `stats` - List of stats to display. Each stat should be a map with the following format:
    - `label` - The name of the stat.
    - `value` - The value of the stat.

