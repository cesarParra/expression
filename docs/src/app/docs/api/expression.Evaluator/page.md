# abstract expression.Evaluator

Evaluates a formula and returns the result.

## Methods
### `global static Object run(String formula)`

Evaluates a formula and returns the result.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Decimal result = (String)expression.Evaluator.run('1 + 1');
```


### `global static Object run(String formula, Configuration config)`

Evaluates a formula and returns the result.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|
|`config`|A configuration object that allows you to set options for        the evaluation.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Decimal result = (String)expression.Evaluator.run(
    '1 + 1',
    new expression.Configuration().printAst()
);
```


### `global static Object run(String formula, SObject context)`

Evaluates a formula and returns the result.

#### Parameters

|Param|Description|
|---|---|
|`formula`|Evaluates a formula and returns the result.|
|`context`|An SObject that will act as the context for the formula.        Providing this allows you to reference fields on the SObject in        the formula.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Account record = new Account(Name = 'Example');
String recordName = (String)expression.Evaluator.run('Name', record);
```


### `global static Object run(String formula, List<SObject> context)`
#### Parameters

|Param|Description|
|---|---|
|`formula`|Evaluates a formula and returns the result.|
|`context`|A list of records that will act as the context for the formula.        Providing this allows you to reference the records through the `@context`        global variable, which will give you a list of records that can be iterated over.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|


**Context** , Name)',    records ); System.assertEquals(new List&lt;String&gt;{'Example 1', 'Example 2'}, recordNames);

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};
List<String> recordNames = (List<String>)expression.Evaluator.run(
  'MAP(
```


### `global static Object run(String formula, SObject context, Configuration config)`
#### Parameters

|Param|Description|
|---|---|
|`formula`|Evaluates a formula and returns the result.|
|`context`|An SObject that will act as the context for the formula.        Providing this allows you to reference fields on the SObject in        the formula.|
|`config`|A configuration object that allows you to set options for        the evaluation.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Account record = new Account(Name = 'Example');
String recordName = (String)expression.Evaluator.run(
   'Name',
   record,
   new expression.Configuration().printAst()
);
```


### `global static Object run(String formula, List<SObject> context, Configuration config)`
#### Parameters

|Param|Description|
|---|---|
|`formula`|Evaluates a formula and returns the result.|
|`context`|A list of records that will act as the context for the formula.        Providing this allows you to reference the records through the `@context`        global variable, which will give you a list of records that can be iterated over.|
|`config`|A configuration object that allows you to set options for        the evaluation.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|


**Context** , Name)',    records,    new expression.Configuration().printAst() ); System.assertEquals(new List&lt;String&gt;{'Example 1', 'Example 2'}, recordNames);

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};
List<String> recordNames = (List<String>)expression.Evaluator.run(
  'MAP(
```


### `global static Object run(String formula, Id recordId)`

Evaluates a formula and returns the result using a record Id as the context.              When using this endpoint field references will automatically be resolved              and queried.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|
|`recordId`|The Id of the record to use as the context for the formula.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Account record = new Account(Name = 'Example');
insert record;
String recordName = (String)expression.Evaluator.run('Name', record.Id);
```


### `global static Object run(String formula, Set<Id> recordIds)`

Evaluates a formula and returns the result using a set of record Ids as the context.              When using this endpoint field references will automatically be resolved              and queried.              The resulting records can be accessed through the `@context` global variable, which              will give you a list of records that can be iterated over.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|
|`recordIds`|The Ids of the records to use as the context for the formula.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|


**Context** , Name)',  new Set&lt;Id&gt;{records[0].Id, records[1].Id} ); System.assertEquals(new List&lt;String&gt;{'Example 1', 'Example 2'}, recordNames);

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;
List<String> recordNames = (List<String)expression.Evaluator.run(
 'MAP(
```


### `global static Object run(String formula, Id recordId, Configuration config)`

Evaluates a formula and returns the result using a record Id as the context.              When using this endpoint field references will automatically be resolved              and queried.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|
|`recordId`|The Id of the record to use as the context for the formula.|
|`config`|A configuration object that allows you to set options for        the evaluation.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|

#### Example
```apex
Account record = new Account(Name = 'Example');
insert record;
String recordName = (String)expression.Evaluator.run(
  'Name',
  record.Id,
  new expression.Configuration().respectSharing(false)
);
```


### `global static Object run(String formula, Set<Id> recordIds, Configuration config)`

Evaluates a formula and returns the result using a set of record Ids as the context.              When using this endpoint field references will automatically be resolved              and queried.              The resulting records can be accessed through the `@context` global variable, which              will give you a list of records that can be iterated over.

#### Parameters

|Param|Description|
|---|---|
|`formula`|The formula to evaluate.|
|`recordIds`|The Ids of the records to use as the context for the formula.|
|`config`|A configuration object that allows you to set options for        the evaluation.|

#### Returns

|Type|Description|
|---|---|
|`Object`|The result of the formula.|


**Context** , Name)',  new Set&lt;Id&gt;{records[0].Id, records[1].Id},  new expression.Configuration().respectSharing(false) ); System.assertEquals(new List&lt;String&gt;{'Example 1', 'Example 2'}, recordNames);

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;
List<String> recordNames = (List<String)expression.Evaluator.run(
 'MAP(
```


---
