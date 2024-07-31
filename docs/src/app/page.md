---
title: Getting started
---

Learn how to get Expression set up in your org.

{% quick-links %}

{% quick-link title="Installation" icon="installation" href="/docs/installation"
description="Instructions on how to get the Expression package." /%}

{% quick-link title="Usage" icon="plugins" href="/docs/usage"
description="Learn how to use the language in your projects." /%}

{% quick-link title="Language Features" icon="presets" href="/docs/lists"
description="Learn how the language works." /%}

{% quick-link title="Standard Library" icon="operators" href="/docs/operators"
description="Learn about the standard library." /%}

{% quick-link title="Advance Usage" icon="theming" href="/docs/custom-functions"
description="Build powerful functionality with the language." /%}

{% quick-link title="Components" icon="components" href="/docs/components/getting-started"  
description="Learn how to use LWC powered by the Expression Languague." /%}

{% /quick-links %}

---

## Quick start

Install the Expression managed package in your Salesforce org.

### Install with SF CLI

```shell
sf package install package --wait 20 --package {% $packageId %}
```

### Install with SFDX CLI

```shell
sfdx force:package:install --apexcompile package --wait 20 --package {% $packageId %}
```

### Setup

Grant the `Expression Admin` permission set to any user that will be configuring and
managing the application.

This permission set grants access to the Expression Playground tab, and the Expression
Function custom metadata type.

## Playground

The Expression Playground tab allows you to test and evaluate formulas in a
visual way.

![Expression Playground](./expression-playground.png)

With it, you can quickly test and validate expressions, and see the results
in real-time. You can also use it to learn about the different operators and
functions available.

To provide a context for the expression, you can also specify a record Id (optional).
