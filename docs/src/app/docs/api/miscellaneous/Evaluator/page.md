---
nextjs:
  metadata:
    title: Evaluator
    description: Api documentation for the Evaluator class
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

Evaluates an expression and returns the result.

#### Signature
```apex
global static Object run(String formula)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| formula | String | The expression to evaluate. |

#### Return Type
**Object**

The result of the expression.

#### Example
```apex
Decimal result = (String)expression.Evaluator.run('1 + 1');
```

---

### `run(expressions)`

Evaluates multiple expressions at same time. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<String> expressions = new List<String>{
  '1 + 1',
  '2 * 2',
  '3 - 1'
};

List<expression.Result> results = expression.Evaluator.run(expressions);

System.assertEquals(3, results.size());
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

### `run(expressions, config)`

Evaluates multiple expressions at same time using a configuration object. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<String> expressions = new List<String>{
  '1 + 1',
  '2 * 2',
  '3 - 1'
};

List<expression.Result> results = expression.Evaluator.run(
  expressions,
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

### `run(expressions, context)`

Evaluates multiple expressions at same time using a context SObject. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, SObject context)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| context | SObject | An SObject that will act as the context for the expressions. Providing this allows you to reference fields on the SObject in the expressions. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account record = new Account(Name = 'Example');
List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'Name', 'Id'},
  record
);

System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
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

### `run(expressions, context)`

Evaluates multiple expressions at same time using a context list of records. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, List<SObject> context)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| context | List&lt;SObject&gt; | A list of records that will act as the context for the expressions. 
Providing this allows you to reference the records through the `@context` global variable, 
which will give you a list of records that can be iterated over. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};

List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
   records
);

System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
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

### `run(expressions, context, config)`

Evaluates multiple expressions at same time using a context SObject. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, SObject context, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| context | SObject | An SObject that will act as the context for the expressions. 
Providing this allows you to reference fields on the SObject in the expressions. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account record = new Account(Name = 'Example');
List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'Name', 'Id'},
  record,
  new expression.Configuration().printAst()
);

System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
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

### `run(expressions, context, config)`

Evaluates multiple expressions at same time using a context list of records. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, List<SObject> context, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| context | List&lt;SObject&gt; | A list of records that will act as the context for the expressions. 
Providing this allows you to reference the records through the `@context` global variable, 
which will give you a list of records that can be iterated over. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<Account> records = new List<Account>{
   new Account(Name = 'Example 1'),
   new Account(Name = 'Example 2')
};

List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
   records,
   new expression.Configuration().printAst()
);

System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
```

---

### `run(expression, recordId)`

Evaluates a formula and returns the result using a record Id as the context. 
When using this endpoint field references will automatically be resolved 
and queried.

#### Signature
```apex
global static Object run(String expression, Id recordId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expression | String | The formula to evaluate. |
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

### `run(expressions, recordId)`

Evaluates multiple expressions at same time using a record Id as the context. 
This endpoints allow you to reference different fields on the record in different expressions, while 
only querying the record once. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, Id recordId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| recordId | Id | The Id of the record to use as the context for the expressions. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account record = new Account(Name = 'Example');
insert record;
List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'Name', 'Id'},
  record.Id
);

System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
```

---

### `run(expression, context, config)`

Evaluates an expression and returns the result using a set of [CustomRecordContext](CustomRecordContext) as the context. 
When using this endpoint field references will automatically be resolved 
and queried. 
 
The resulting record can be accessed through a global variable named after the 
key specified in the [CustomRecordContext](CustomRecordContext) . 
 
For example, if you create a [CustomRecordContext](CustomRecordContext) with the key `TargetAccount` , 
you can reference fields on that record using `@TargetAccount.FieldName` in your formula.

#### Signature
```apex
global static Object run(String expression, CustomRecordContext context, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expression | String | The formula to evaluate. |
| context | [CustomRecordContext](CustomRecordContext) | The CustomRecordContext to use as the context for the formula. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for 
the evaluation. |

#### Return Type
**Object**

The result of the formula.

#### Example
```apex
Account accountRecord = new Account(Name = 'Acme');
insert accountRecord;

CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);

String expressionFormula = '@TargetAccount.Name';
Object result = Evaluator.run(expressionFormula, customRecordContext, new Configuration());
```

---

### `run(expression, contexts, config)`

Evaluates an expression using a set of [CustomRecordContext](CustomRecordContext) as the context. 
 
The resulting record can be accessed through a global variable named after the 
key specified in each provided [CustomRecordContext](CustomRecordContext) . 
 
For example, if you create one [CustomRecordContext](CustomRecordContext) with the key `TargetAccount` , 
and another with the key `SourceContact` , 
you can reference fields on those records using `@TargetAccount.FieldName` and `@SourceContact.FieldName` 
in your expressions.

#### Signature
```apex
global static Object run(String expression, List<CustomRecordContext> contexts, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expression | String | The expression to evaluate. |
| contexts | List&lt;CustomRecordContext&gt; | The CustomRecordContexts to use as the context for the expressions. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for 
the evaluation. |

#### Return Type
**Object**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account accountRecord = new Account(Name = 'Acme', NumberOfEmployees = 50);
insert accountRecord;

Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe');
insert contactRecord;

CustomRecordContext accountRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
CustomRecordContext contactRecordContext = new CustomRecordContext('TargetContact', contactRecord.Id);

String expressionFormula = '@TargetContact.LastName + TEXT(@TargetAccount.NumberOfEmployees)';
Object result = Evaluator.run(expressionFormula,
    new List<CustomRecordContext> { accountRecordContext, contactRecordContext }, new Configuration());
```

---

### `run(expressions, contexts, config)`

Evaluates multiple expressions at same time using a set of [CustomRecordContext](CustomRecordContext) as the context. 
This endpoints allow you to reference different fields on the records in different expressions, while 
only querying the records once. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, List<CustomRecordContext> contexts, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| contexts | List&lt;CustomRecordContext&gt; | The CustomRecordContexts to use as the context for the expressions. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for 
the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account accountRecord = new Account(Name = 'Acme', NumberOfEmployees = 50);
insert accountRecord;

Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe');
insert contactRecord;

CustomRecordContext accountRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
CustomRecordContext contactRecordContext = new CustomRecordContext('TargetContact', contactRecord.Id);

List<String> expressions = new List<String>{
  '@TargetAccount.Name',
  '@TargetContact.LastName + TEXT(@TargetAccount.NumberOfEmployees)'
};

List<expression.Result> results = expression.Evaluator.run(
  expressions,
  new List<CustomRecordContext> { accountRecordContext, contactRecordContext },
  new expression.Configuration()
);

System.assertEquals(2, results.size());
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

### `run(expressions, recordIds)`

Evaluates multiple expressions at same time using a set of record Ids as the context. 
This endpoints allow you to reference different fields on the records in different expressions, while 
only querying the records once. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, Set<Id> recordIds)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| recordIds | Set&lt;Id&gt; | The Ids of the records to use as the context for the expressions. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;

List<String> recordNames = (List<String)expression.Evaluator.run(
 new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
 new Set<Id>{records[0].Id, records[1].Id}
);

System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
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

### `run(expressions, recordId, config)`

Evaluates multiple expressions at same time using a record Id as the context. 
This endpoints allow you to reference different fields on the record in different expressions, while 
only querying the record once. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, Id recordId, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| recordId | Id | The Id of the record to use as the context for the expressions. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
Account record = new Account(Name = 'Example');
insert record;
List<String> recordNames = (List<String>)expression.Evaluator.run(
  new List<String>{'Name', 'Id'},
  record.Id,
  new expression.Configuration().respectSharing(false)
);

System.assertEquals(new List<String>{'Example', record.Id}, recordNames);
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

### `run(expressions, recordIds, config)`

Evaluates multiple expressions at same time using a set of record Ids as the context. 
This endpoints allow you to reference different fields on the records in different expressions, while 
only querying the records once. 
 
{% callout %} 
It is not possible to use function definitions in bulk evaluations. 
{% /callout %}

#### Signature
```apex
global static List<Result> run(List<String> expressions, Set<Id> recordIds, Configuration config)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| expressions | List&lt;String&gt; | The expressions to evaluate. |
| recordIds | Set&lt;Id&gt; | The Ids of the records to use as the context for the expressions. |
| config | [Configuration](Configuration) | A configuration object that allows you to set options for 
the evaluation. |

#### Return Type
**List&lt;Result&gt;**

The results of the expressions. Results are returned in the same order as the expressions.

#### Example
```apex
List<Account> records = new List<Account>{
  new Account(Name = 'Example 1'),
  new Account(Name = 'Example 2')
};
insert records;

List<String> recordNames = (List<String)expression.Evaluator.run(
 new List<String>{'MAP(@context, Name)', 'COUNT(@context)'},
 new Set<Id>{records[0].Id, records[1].Id},
 new expression.Configuration().respectSharing(false)
);

System.assertEquals(new List<String>{'Example 1', 'Example 2', '2'}, recordNames);
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