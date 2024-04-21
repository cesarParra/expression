---
title: Form Builder
nextjs:
  metadata:
    title: Form Builder
    description: Learn how to build forms with ease using the Form component and its related components.
---

Expression Components include a set of components that allow you to build forms with ease.
The components are designed to work together and provide a seamless experience when building forms.

The core component when building a form is the `Form` component. It exposes a region where you can place other
Expression components inside. This allows you to essentially "build" a form that then be submitted through a `Button`
component with a `submit` type.

Submitted forms will pass all the information of any embedded input components within the region
to the Apex class specified in the `src` handler of the `Button`.
