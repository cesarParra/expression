---
title: Features
nextjs:
  metadata:
    title: Features
    description: Learn about the Features component.
---

The `Features` component allows you to display a list of features. It can be used
to display a list of features, benefits, etc.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Features](./../../assets/components/features/features.png)

## Data Structure

```
{
    title?: string,
    description?: string,
    features: [
        {
            title: string,
            description: string
        }
    ]
}
```

- `title` Optional - The title to display.
- `description` Optional - The description to display.
- `features` - List of features to display. Each feature should be a map with the following format:
    - `title` - The title of the feature.
    - `description` - The description of the feature.
