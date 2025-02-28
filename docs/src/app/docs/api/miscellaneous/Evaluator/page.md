---
nextjs:
  metadata:
    title: Evaluator
    description: Api documentation for the Evaluator class}
---

# Evaluator Class
`abstract`

The `Evaluator` class is the main entry point for evaluating expressions. 
It provides a set of static methods that allow you to evaluate expressions 
in a variety of contexts.

## Namespace
expression

## Methods
### `run(formula)`

Evaluates a formula and returns the result.

#### Signature
```apex
global static Object run(String formula)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Decimal result = (String)expression.Evaluator.run('1 + 1');
```

---

### `run(formula, config)`

Evaluates a formula and returns the result.

#### Signature
```apex
global static Object run(String formula, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Decimal result = (String)expression.Evaluator.run(
    '1 + 1',
    new expression.Configuration().printAst()
);
```

---

### `run(formula, context)`

Evaluates a formula and returns the result.

#### Signature
```apex
global static Object run(String formula, SObject context)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | Evaluates a formula and returns the result. |
| context | SObject | An SObject that will act as the context for the formula. Providing this allows you to reference fields on the SObject in the formula. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Account record = new Account(Name = 'Example');
String recordName = (String)expression.Evaluator.run('Name', record);
```

---

### `run(expression, context)`

Evaluates an expression and returns the result.

#### Signature
```apex
global static Object run(String expression, List<SObject> context)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expression | String | The expression to evaluate. |
| context | List&lt;SObject&gt; | A list of records that will act as the context for the expression. Providing this allows you to reference the records through the `@context` global variable, which will give you a list of records that can be iterated over. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};

List<String> recordNames = (List<String>)expression.Evaluator.run(
  'MAP(@context, Name)',
   records
);

System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
```

---

### `run(formula, context, config)`

Evaluates a formula and returns the result.

#### Signature
```apex
global static Object run(String formula, SObject context, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The expression to evaluate |
| context | SObject | An SObject that will act as the context for the formula. Providing this allows you to reference fields on the SObject in the formula. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Account record = new Account(Name = 'Example');
String recordName = (String)expression.Evaluator.run(
   'Name',
   record,
   new expression.Configuration().printAst()
);
```

---

### `run(formula, context, config)`

Evaluates a formula and returns the result.

#### Signature
```apex
global static Object run(String formula, List<SObject> context, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The expression to evaluate. |
| context | List&lt;SObject&gt; | A list of records that will act as the context for the formula. Providing this allows you to reference the records through the `@context` global variable, which will give you a list of records that can be iterated over. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};

List<String> recordNames = (List<String>)expression.Evaluator.run(
  'MAP(@context, Name)',
   records,
   new expression.Configuration().printAst()
);

System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
```

---

### `run(formula, recordId)`

Evaluates a formula and returns the result using a record Id as the context. 
When using this endpoint field references will automatically be resolved 
and queried.

#### Signature
```apex
global static Object run(String formula, Id recordId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |
| recordId | Id | The Id of the record to use as the context for the formula. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Account record = new Account(Name = 'Example');
insert record;
String recordName = (String)expression.Evaluator.run('Name', record.Id);
```

---

### `run(formula, recordIds)`

Evaluates a formula and returns the result using a set of record Ids as the context. 
When using this endpoint field references will automatically be resolved 
and queried. 
 
The resulting records can be accessed through the `@context` global variable, which 
will give you a list of records that can be iterated over.

#### Signature
```apex
global static Object run(String formula, Set<Id> recordIds)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |
| recordIds | Set&lt;Id&gt; | The Ids of the records to use as the context for the formula. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;

List<String> recordNames = (List<String)expression.Evaluator.run(
 'MAP(@context, Name)',
 new Set<Id>{records[0].Id, records[1].Id}
);

System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
```

---

### `run(formula, recordId, config)`

Evaluates a formula and returns the result using a record Id as the context. 
When using this endpoint field references will automatically be resolved 
and queried.

#### Signature
```apex
global static Object run(String formula, Id recordId, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |
| recordId | Id | The Id of the record to use as the context for the formula. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**Object**

The result of the formula.

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

### `run(formula, recordIds, config)`

Evaluates a formula and returns the result using a set of record Ids as the context. 
When using this endpoint field references will automatically be resolved 
and queried. 
 
The resulting records can be accessed through the `@context` global variable, which 
will give you a list of records that can be iterated over.

#### Signature
```apex
global static Object run(String formula, Set<Id> recordIds, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The formula to evaluate. |
| recordIds | Set&lt;Id&gt; | The Ids of the records to use as the context for the formula. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for 
the evaluation. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;

List<String> recordNames = (List<String)expression.Evaluator.run(
 'MAP(@context, Name)',
 new Set<Id>{records[0].Id, records[1].Id},
 new expression.Configuration().respectSharing(false)
);

System.assertEquals(new List<String>{'Example 1', 'Example 2'}, recordNames);
```

---

### `retrieveRecordForFormulas(recordId, formulas)`

Analyzes multiple formulas and retrieves a record with all fields needed by those formulas. 
This is useful when you need to query a record once with all required fields for multiple 
formula evaluations, rather than letting each formula evaluation perform its own query.

#### Signature
```apex
global static SObject retrieveRecordForFormulas(Id recordId, List<String> formulas)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| recordId | Id | The Id of the record to retrieve |
| formulas | List&lt;String&gt; | List of formulas to analyze |

#### Return Type
**SObject**

SObject The record populated with all fields referenced in the formulas

#### Example
```apex
Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
List<String> formulas = new List<String>{
  'Name',
  'BillingCity',
  'Owner.Name'
};
Account account = (Account)expression.Evaluator.retrieveRecordForFormulas(accountId, formulas);
// Now use the account record which contains all the needed fields
String accountName = (String)account.get('Name');
String ownerName = (String)account.getSObject('Owner').get('Name');
```