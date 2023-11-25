---
title: Getting started
---

Learn how to get Expression set up in your org.

{% quick-links %}

{% quick-link title="Installation" icon="installation" href="/" description="Instructions on how to get the Expression package." /%}

{% quick-link title="Usage" icon="plugins" href="/" description="Learn how to use the language in your projects." /%}

{% quick-link title="Architecture guide" icon="presets" href="/" description="Learn how the code works and contribute." /%}

{% quick-link title="API reference" icon="theming" href="/" description="Learn about the endpoints exposed by the package to Apex developers." /%}

{% quick-link title="Expression Components" icon="theming" href="/" description="LWC Library powered by the Expression language." /%}

{% /quick-links %}

---

## Quick start

Install the Expression managed package in your Salesforce org.

### Install with SF CLI

```shell
sf package install --apex-compile package --wait 20 --package 04tDm000000tLMTIA2
```

### Install with SFDX CLI

```shell
sfdx force:package:install --apexcompile package --wait 20 --package 04tDm000000tLMTIA2
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
