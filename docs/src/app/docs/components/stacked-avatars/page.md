---
title: Stacked Avatars
nextjs:
  metadata:
    title: Stacked Avatars
    description: Expression Stacked Avatars Component
---

The `Avatar (Stacked)` component is used to display many avatars stacked on top
of each other. It is useful when you want to display multiple users in a small
space.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Stacked Avatars](./../../assets/components/stackedAvatars/stackedAvatars.png)

## Data Structure

The `Avatar (Stacked)` component expects an Expression that evaluates to the following
data structure:

```
[
    { avatarUrl: string } |
    { initials: string } |
    { useIcon: boolean }
]
```

It receives a list of objects that can either have an `avatarUrl` property, which is a string that represents
the URL of the image to display, or an `initials` property, which is a string
that represents the initials of the user. If the `useIcon` property is set to
`true`, the component will display an icon instead of an image.

## Properties

* Size: The size of the avatar. It can be `small`, `medium`, or `large`.
* Style: The style of the avatar. It can be `circle`, `rounded`, or `square`.
