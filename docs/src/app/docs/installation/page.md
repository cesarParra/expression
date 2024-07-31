---
title: Installation
nextjs:
  metadata:
    title: Installation
    description: Install the Expression package.
---

Expression can be installed in your Salesforce org through an Unlocked package.

---

## Install with SF CLI

```bash
sf package install --wait 20 --package {% $packageId %}
```

## Install with SFDX CLI

```shell
sfdx force:package:install --wait 20 --package {% $packageId %}
```

## Setup

Grant the `Expression Admin` permission set to any user that will be configuring and
managing the application.

This permission set grants access to the Expression Playground tab, and the Expression
Function custom metadata type.
