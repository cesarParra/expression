---
title: Avatar
nextjs:
  metadata:
    title: Avatar
    description: Expression Avatar Component
---

The `Avatar` component is used to display a user's profile picture or initials.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Example

![Avatar](./../../assets/components/avatar/avatar.png)

## Data Structure

The `Avatar` component expects an Expression that evaluates to the following
data structure:

```
{ avatarUrl: string } |
{ initials: string } |
{ useIcon: boolean }
```

It can either have an `avatarUrl` property, which is a string that represents
the URL of the image to display, or an `initials` property, which is a string
that represents the initials of the user. If the `useIcon` property is set to
`true`, the component will display an icon instead of an image.

## Properties

* Size: The size of the avatar. It can be `small`, `medium`, or `large`.
* Style: The style of the avatar. It can be `circle`, `rounded`, or `square`.
