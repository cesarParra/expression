---
title: Text Block
nextjs:
  metadata:
    title: Text Block
    description: Learn about the Text Block component.
---

The `Text Block` component allows you to display a block of text. It can be used
to display any row of text.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

### Example

Given a simple string:

```
"📅 17 - 19 October 2022 ◆ 🗺️Los Angeles, CA"
```

The following is procuded:

![Text Block](./../../assets/components/textBlock/textBlock.png)

Note that the input can include emojis and can be as complex as necessary, as long as it produces a string in the end.
For example, take this expression which retrieves the start and end dates of an event and formats them
using built-in date functions:

```
Query(expression__Event__c(where: Name = "ExpressionConf")[Id, Name, Start_Date__c, End_Date__c])
    -> FIRST()
    -> TRANSFORM(
        "📅 ${TEXT(DAY($source.expression__Start_Date__c))} - ${DATETIMEFORMAT(DATETODATETIME($source.expression__End_Date__c), "dd MMMM yyyy")} ◆ 🗺️Los Angeles, CA"     
       )
````

It produces the same output as the simple string above:

![Text Block](./../../assets/components/textBlock/textBlock.png)

### Data Structure

The `Text Block` component expects an Expression that evaluates to the following
data structure:

```
string
```
