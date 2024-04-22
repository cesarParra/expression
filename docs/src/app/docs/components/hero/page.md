---
title: Hero
nextjs:
  metadata:
    title: Hero
    description: Learn about the Hero component.
---

The `Hero` component allows you to display a hero image with a title and description. It can be used
in a community page.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Hero](./../../assets/components/hero/hero.png)

### Data Structure

```
{
    title: string,
    description?: string,
    callToAction?: Button,
    secondaryAction?: Button,
    bannerImage?: string
}
```

- `title` - The title to display.
- `description` Optional - The description to display.
- `callToAction` Optional - `Button Action type` -> The action to execute. Expects the same format as the `Button`
  component.
- `secondaryAction` Optional - `Button Action type` -> The action to execute. Expects the same format as the `Button`
  component.
- `bannerImage` Optional - The URL of the image to display.
