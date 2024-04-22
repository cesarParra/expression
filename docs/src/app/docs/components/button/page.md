---
title: Button
nextjs:
  metadata:
    title: Button
    description: Learn about the Button component.
---

{% badge text="Form Compatible" color="green" /%}

The `Button` component allows you to display a button that can be used to trigger an action or navigate to a URL.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Data Structure

```
{
   label: string,
   type: 'submit' | 'action' | 'navigation_namedPage' | 'navigation_url',
   src: string,
   callback: string
}
```

* `label` - Expression that evaluates to a String - The label to display on the button.
* `type` - Expression that evaluates to a String - The type of button to display. Valid values
  are `submit`, `action`, `navigation_namedPage`, `navigation_url`
* `src` - Depending on the `type` specified, this can hold one of the following values:
    * `submit` or `action` - Reference to an Apex action to execute using the `$Action.Apex.ClassName` format.
    * `navigation_namedPage` - The API name of the page to navigate to.
    * `navigation_url` - The URL to navigate to.
* `callback` - Only to be used when the `action` type is specified. This should be a reference to an LWC action using
  the
  `$Action.LWC.ActionName` format. The special variable `$returnValue` can be used to reference the return value of the
  action.

## Action Types

The `type` property determines how the button will behave when clicked. The following types are supported with their
respective behaviors:

* `submit`

To use this type the button must be placed inside a `Form` component. When clicked, the form will be submitted (the
Apex action referenced in the `src` property will be executed) receiving the form data as a Map.

* `action`

When clicked, the Apex action referenced in the `src` property will be executed.

* `navigation_namedPage`

When clicked, the user will be navigated to the page referenced in the `src` property. The `src` property should
evaluate to a String containing the API name of the page to navigate to.

* `navigation_url`

When clicked, the user will be navigated to the URL referenced in the `src` property. The `src` property should
evaluate to a String containing the URL to navigate to.

**Example**

```
{
  "label": "Checkout",
  "type": "action",
  "src": $Action.Apex.CreateSalesOrder("00A56643Dr563lcwkL"),
  "callback": $Action.Lwc.GoToNamedPage({
    "name": "checkout__c",
    "id": $returnValue
  })
}
```

![Button](./../../assets/components/button/button.png)

For more on how to call Apex actions, see [Apex Interoperability]('./../../apex-interop)

## Callbacks

After executing an action, it is common to want to react to that action in some way. This is accomplished
through callbacks and LWC Interoperability. To reference an LWC callback,
use the `$Action.Lwc.ActionName(parameter_expression)` format.

The following LWC action names are supported:

* `GoToNamedPage`

This action navigates to a named page. A Map expression with a "name" property must be provided containing
the page's API Name.
To add query parameters to the URL, pass as many extra keys to the map as you wish.

```json
{
  "name": "pageApiName",
  "namedParam1": "success",
  "namedParam2": "any_value"
}
```

* `GoToUrl`

This action navigates to a URL. A Map expression with a "name" property must be provided containing the URL.

```json
{
  "name": "pageApiName"
}
```

* `Reload`

This action reloads the page.
