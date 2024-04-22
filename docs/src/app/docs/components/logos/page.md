---
title: Logos
nextjs:
  metadata:
    title: Logos
    description: Learn about the Logos component.
---

The `Logos` component allows you to display a list of logos. It can be used
to display a list of sponsors, partners, clients, etc.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Logos](./../../assets/components/logos/logos.png)

## Data Structure

```
{
    title: string,
    logos: [
        {
            name: string,
            src: string
        }
    ]
}
```

- `title` - The title to display.
- `logos` - List of logos to display. Each logo should be a map with the following format:
    - `name` - The name of the logo.
    - `src` - The URL of the image to display.

