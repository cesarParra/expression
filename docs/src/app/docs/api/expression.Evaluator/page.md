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


---
