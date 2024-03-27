---
title: Getting Started with Expression Components
nextjs:
  metadata:
    title: Getting Started with Expression Components
    description: Learn about how to get started with the Expression Components library.
---

`Expression Components` is a UI library included that can be deployed independently of the core library.
These components give you powerful configuration abilities, as their configuration properties are powered
by the `Expression` language.

## Installation

Install with SF CLI:

```shell
sf package install --apex-compile package --wait 20 --package 04tHu000003OWFLIA4
```

Install with SFDX CLI:

```shell
sfdx force:package:install --apexcompile package --wait 20 --package 04tHu000003OWFLIA4
```

## Site Context

### Query Parameters

From any expression you can access query parameters for the current page using
the global context variable prefix `@` followed by the query parameter name:

```
"Hello ${@name}"
```

where `name` is a query parameter in the current page.

> 📓 All components supported in communities are meant to be used within an LWR template. They might
> work in Aura templates, but keep in mind they developed and tested with LWR in mind.
