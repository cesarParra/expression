---
title: Referencing Org Data
nextjs:
  metadata:
    title: Referencing Org Data
    description: Learn how to reference data from your org.
---

## Custom Labels

You can reference custom labels using the `$Label` global variable.

{% callout type="warning" title="Be Aware.." %}
A namespace needs to be provided when referencing a label. To use the current namespace
(or no namespace at all), use the letter `c`.
{% /callout %}

Label references will automatically be translated to the current user's language.

```apex
Object result = expression.Evaluator.run('$Label.c.MyCustomLabel');
Object result = expression.Evaluator.run('$Label.namespace.MyCustomLabel');
```

## Custom Metadata

You can reference custom metadata records using the `$CustomMetadata` global variable.

To access the data of a custom metadata record, you need to specify the type, the record name, and the field:

```apex
Object result = expression.Evaluator.run('$CustomMetadata.MyCustomMetadataType.MyCustomMetadataRecord.MyField__c');
```

## Static Resources

You can reference static resources using the `$Resource` global variable.

This will return the URL where the static resource is hosted.

```apex
Object result = expression.Evaluator.run('$Resource.MyStaticResourceName');
```

## Current User

You can reference information about the current user through the `$User` global variable.

Available references are:

* `DefaultCurrency`
* `FirstName`
* `Language`
* `LastName`
* `Locale`
* `Name`
* `TimeZone`
* `Email`

```apex
Object result = expression.Evaluator.run('$User.FirstName');
```

## User Settings

You can reference user settings using the `$UserSettings` global variable.

This global variable wraps all properties of the `ConnectApi.UserSettings` class,
so please reference
the [documentation for that class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_connectapi_output_usersettings.htm)
for available properties.

```apex
Object result = expression.Evaluator.run('$UserSettings.hasChatter');
```

### Time Zone

The `timeZone` property of the `$UserSettings` global variable returns a map containing
`name` and `gmtOffset` properties.

```apex
Object result = expression.Evaluator.run('$UserSettings.timeZone.name');
Object gmtOffset = expression.Evaluator.run('$UserSettings.timeZone.gmtOffset');
```

## Organization

You can reference information about the current organization through the `$Organization` global variable.

Available references are:

* `OrgId`
* `Name`

## Permission

{% callout type="warning" title="Usage Warning" %}
Due to limitations with calling `FeatureManagement.checkPermission` from within a managed package, Expression
checks permissions by querying the `CustomPermission` and `SetupEntityAccess` objects.

This means that each permission check will consume 2 SOQL queries the first time it is evaluated (checks are
cached afterwards).
{% /callout %}

Allows you to reference information about the current user’s custom permission access.

```
$Permission.MyCustomPermissionName # Returns true if the user has access to the custom permission, false otherwise.
```

To reference a custom permission that has a namespace, separate the namespace and the permission name with double
underscores (`__`):

```
$Permission.namespace__MyCustomPermissionName # Returns true if the user has access to the custom permission, false otherwise.
```

## Setup

{% callout type="warning" title="Usage Warning" %}
Using this endpoint consumes SOQL queries.
{% /callout %}

A global merge field type to use when referencing a custom setting of type “hierarchy.”

Use it to access hierarchical custom settings and their field values using dot notation. For example, $
Setup.App_Prefs__c.Show_Help_Content__c.

Hierarchical custom settings allow values at any of three different levels:

- Organization, the default value for everyone
- Profile, which overrides the Organization value
- User, which overrides both Organization and Profile values

The correct value is automatically determined for the field based on the running user’s current context.

```
$Setup.CustomSettingName__c.CustomFieldName__c
```
