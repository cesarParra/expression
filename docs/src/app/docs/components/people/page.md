---
title: People
nextjs:
  metadata:
    title: People
    description: Learn about the People component.
---

The `People` component allows you to display a list of people. It can be used
to display a list of team members, board members, event speakers, etc.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![People](./../../assets/components/people/people.png)

## Data Structure

```
{
    title: string,
    description?: string,
    people: [
        {
            name: string,
            title: string,
            imageUrl: string,
            about?: string
        }
    ]
}
```

- `title` - The title to display.
- `description` Optional - The description to display.
- `people` - List of people to display. Each person should be a map with the following format:
    - `name` - The name of the person.
    - `title` - The title of the person.
    - `imageUrl` - The URL of the image to display.
    - `about` - Optional - The description of the person.

