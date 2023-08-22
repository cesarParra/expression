# Formula Evaluator

Allows you to evaluate formula-like syntax through Apex code.

Supports most of the operators and functions available in Salesforce formulas, but
also has additional support for collections/lists.

## Installation

### Deploy to Salesforce

Clone the repo and deploy the source code, or click the button below to directly deploy to Salesforce.

[![Deploy to Salesforce](assets/deploy.png)](https://githubsfdeploy.herokuapp.com/app/githubdeploy/cesarParra/formula-evaluator)

## Usage

Use `FormulaEvaluator` class to evaluate formulas.

```apex
String formula = '1 + 1';
Object result = FormulaEvaluator.evaluate(formula);
Assert.areEqual(2, result);
```

You can also evaluate formulas providing an SObject as context. This allows you to
make reference to fields of the provided SObject in the formula.

When using this endpoint, the user is in charge of providing the correct context
with the correct fields being referenced in the formula correctly queried.

```apex
Account account = new Account(Name = 'ACME');
Object result = FormulaEvaluator.evaluate('Name', account);
Assert.areEqual('ACME', result);
```

If you want the framework to take care of querying the correct fields, you can
use the `evaluate` method that takes a record Id as context.

```apex
Account account = new Account(Name = 'ACME');
insert account;

Object result = FormulaEvaluator.evaluate('Name', account.Id);
Assert.areEqual('ACME', result);
```

References to child records are also supported. You can reference fields on child
records by first extracting a list out of the child records using the `TOLIST`
and then using any of the list functions to compute information from that list.

When referencing child data in this way, the framework will take care of any necessary
subqueries, so only one SOQL query is consumed.

Referencing parent relationships through dot notation is also supported by both
endpoints (the one that takes an SObject as context and the one that takes a record Id).

```apex
Account parentAccount = new Account(Name = 'ACME');
insert parentAccount;

Account childAccount = new Account(Name = 'ACME Child', ParentId = parentAccount.Id);
insert childAccount;

Object result = FormulaEvaluator.evaluate('Parent.Name', childAccount.Id);
Assert.areEqual('ACME', result);
```

### Considerations and Limitations

There are a few limitations around merge fields at the moment

- When using the endpoint that takes a record Id as the context, the query
is performed `with sharing`, so any records that the user does not have access to
will not be returned or taken into account in the operation.
- When extracting data out of child records through the TOLIST function, any null
value is skipped. Take this into account when computing information using list
functions.

## Collections/List Support

To work with collections/lists, you can use the `LIST` function

```apex
Object result = FormulaEvaluator.evaluate('LIST(1, 2, 3)'); // (1, 2, 3)
```

## Supported Operators and Functions

### Operators

#### Math Operators

- `+` Addition

```apex
FormulaEvaluator.evaluate('1 + 1'); // 2
```

- `-` Subtraction

```apex
FormulaEvaluator.evaluate('1 - 1'); // 0
```

- `*` Multiplication

```apex
FormulaEvaluator.evaluate('2 * 2'); // 4
```

- `/` Division

```apex
FormulaEvaluator.evaluate('4 / 2'); // 2
```

- `^` Exponentiation

```apex
FormulaEvaluator.evaluate('2 ^ 2'); // 4
```

#### Misc

- `( )` Parentheses

Groups expressions together.

```apex
FormulaEvaluator.evaluate('(1 + 1) * 2'); // 4
```

#### Logical Operators

- `=` and `==` Equal

Evaluates if two values are equal. The `=` and `==` operators are equivalent.

```apex
FormulaEvaluator.evaluate('1 = 1'); // true
```

- `<>` and `!=` Not Equal

Evaluates if two values are not equal. The `<>` and `!=` operators are equivalent.

```apex
FormulaEvaluator.evaluate('1 <> 2'); // true
```

- `<` Less Than

Evaluates if the first value is less than the second value.

```apex
FormulaEvaluator.evaluate('1 < 2'); // true
```

- `>` Greater Than

Evaluates if the first value is greater than the second value.

```apex
FormulaEvaluator.evaluate('2 > 1'); // true
```

- `<=` Less Than or Equal

Evaluates if the first value is less than or equal to the second value.

```apex
FormulaEvaluator.evaluate('1 <= 1'); // true
```

- `>=` Greater Than or Equal

Evaluates if the first value is greater than or equal to the second value.

```apex
FormulaEvaluator.evaluate('1 >= 1'); // true
```

- `&&` Logical AND

Evaluates if both values are true.

```apex
FormulaEvaluator.evaluate('true && true'); // true
```

- `||` Logical OR

Evaluates if either value is true.

```apex
FormulaEvaluator.evaluate('true || false'); // true
```

#### String Operators

- `&` and `+` Concatenation

Concatenates two strings together. The `&` and `+` operators are equivalent.

```apex
FormulaEvaluator.evaluate('"Hello" & " " & "World"'); // "Hello World"
```

### Functions

#### Logical Functions

- `AND`

Returns a TRUE response if all values are true; returns a FALSE response if one or more values are false.

Accepts multiple arguments, but must have at least 2.

```apex
FormulaEvaluator.evaluate('AND(true, true)'); // true
FormulaEvaluator.evaluate('AND(true, false, true)'); // false
```

- `IF`

Returns one value if a condition is true and another value if it's false.

Accepts 3 arguments: the condition, the value if true, and the value if false.

```apex
FormulaEvaluator.evaluate('IF(true, "Hello", "World")'); // "Hello"
FormulaEvaluator.evaluate('IF(false, "Hello", "World")'); // "World"
```

- `NOT`

Reverses the logical value of its argument.

```apex
FormulaEvaluator.evaluate('NOT(true)'); // false
```

- `OR`

Returns a TRUE response if any value is true; returns a FALSE response if all values are false.

Accepts any number of arguments.

```apex
FormulaEvaluator.evaluate('OR(true, false)'); // true
FormulaEvaluator.evaluate('OR(false, false)'); // false
```

- `BLANKVALUE`

Returns a specified value if the expression is blank (null value or empty string); otherwise, returns the result of the
expression.

Accepts 2 arguments: the expression and the value to return if the expression is blank.

```apex
FormulaEvaluator.evaluate('BLANKVALUE(null, "Hello")'); // "Hello"
FormulaEvaluator.evaluate('BLANKVALUE("World", "Hello")'); // "World"
```

- `ISBLANK`

Returns TRUE if the expression is blank (null value or empty string); otherwise, returns FALSE.

Accepts 1 argument: the expression to check.

```apex
FormulaEvaluator.evaluate('ISBLANK(null)'); // true
FormulaEvaluator.evaluate('ISBLANK("")'); // true
FormulaEvaluator.evaluate('ISBLANK("Hello")'); // false
```

#### String Functions

- `BEGINS`

Returns TRUE if the first character(s) in a text field match a given string.

Accepts 2 arguments: the text field and the string to match.

```apex
FormulaEvaluator.evaluate('BEGINS("Hello World", "Hello")'); // true
```

- `CONTAINS`

Returns TRUE if a text field contains a given string.

Accepts 2 arguments: the text field and the string to match.

```apex
FormulaEvaluator.evaluate('CONTAINS("Hello World", "llo Wo")'); // true
```

- `LOWER`

Converts all letters in the specified text to lowercase.

Accepts 1 argument: the text to convert.

```apex
FormulaEvaluator.evaluate('LOWER("Hello World")'); // "hello world"
```

- `FIND`

Returns the starting position of one text string within another text string. If the text string is not found, FIND
returns a value -1.

Accepts either 2 or 3 arguments: the text to find, the text to search, and optionally the starting position.

```apex
FormulaEvaluator.evaluate('FIND("World", "Hello World")'); // 6
FormulaEvaluator.evaluate('FIND("World", "Hello World", 7)'); // -1
```

- `LEFT`

Returns the specified number of characters from the beginning of a text string.

Accepts 2 arguments: the text to evaluate and the number of characters to return.

```apex
FormulaEvaluator.evaluate('LEFT("Hello World", 5)'); // "Hello"
```

- `LEN`

Returns the number of characters in a text string.

Accepts 1 argument: the text to evaluate.

```apex
FormulaEvaluator.evaluate('LEN("Hello World")'); // 11
```

- `LPAD`

Returns a text value padded to the specified length with the specified set of characters.

Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
If the padding character is not specified, it defaults to a space.

```apex
FormulaEvaluator.evaluate('LPAD("Hello", 10)'); // "     Hello"
FormulaEvaluator.evaluate('LPAD("Hello", 10, "*")'); // "*****Hello"
```

- `RPAD`

Returns a text value padded to the specified length with the specified set of characters.

Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
If the padding character is not specified, it defaults to a space.

```apex
FormulaEvaluator.evaluate('RPAD("Hello", 10)'); // "Hello     "
FormulaEvaluator.evaluate('RPAD("Hello", 10, "*")'); // "Hello*****"
```

- `REVERSE`

Returns a text value with the order of the characters reversed.

Accepts 1 argument: the text to reverse.

```apex
FormulaEvaluator.evaluate('REVERSE("Hello World")'); // "dlroW olleH"
```

- `MID`

Returns a specified number of characters from a text string starting at the position you specify up
to the number of characters you specify.

Note that the position is 1-based, not 0-based.

Accepts 3 arguments: the text to evaluate, the starting position, and the number of characters to return.

```apex
FormulaEvaluator.evaluate('MID("Hello World", 7, 5)'); // "World"
```

- `SUBSTRING`

Returns a specified number of characters from a text string starting at the position you specify.
Optionally, you can specify the number of characters to return.

Note that the position is 1-based, not 0-based.

Accepts 2 or 3 arguments: the text to evaluate and the starting position. Optionally, the number of characters to

```apex
FormulaEvaluator.evaluate('SUBSTRING("Hello World", 7)'); // "World"
FormulaEvaluator.evaluate('SUBSTRING("Hello World", 7, 5)'); // "World"
```

- `RIGHT`

Returns the specified number of characters from the end of a text string.

Accepts 2 arguments: the text to evaluate and the number of characters to return.

If the second argument is a negative number, it gets treated as a 0

```apex
FormulaEvaluator.evaluate('RIGHT("Hello World", 5)'); // "World"
FormulaEvaluator.evaluate('RIGHT("Hello World", -5)'); // ""
```

#### Date and Time Functions

- `DATE`

Returns a date value from the provided year, month, and day values.

Accepts 3 arguments: the year, month, and day.

```apex
FormulaEvaluator.evaluate('DATE(2020, 1, 1)'); // 2020-01-01 00:00:00
```

- `ADDMONTHS`

Returns a date that is a specified number of months before or after a given date.

Accepts 2 arguments: the date and the number of months to add.

```apex
FormulaEvaluator.evaluate('ADDMONTHS(DATE(2020, 1, 1), 1)'); // 2020-02-01 00:00:00
```

- `DAY`

Returns the day of the month, a number from 1 to 31.

Accepts 1 argument: the date to evaluate.

```apex
FormulaEvaluator.evaluate('DAY(DATE(2020, 1, 1))'); // 1
```

- `DAYOFYEAR`

Returns the day of the year, a number from 1 to 366.

Accepts 1 argument: the date to evaluate.

```apex
FormulaEvaluator.evaluate('DAYOFYEAR(DATE(2020, 1, 1))'); // 1
```

- `NOW`

Returns the current Datetime in the GMT time zone.

Accepts no arguments.

```apex
FormulaEvaluator.evaluate('NOW()'); // 2020-01-01 00:00:00
```

- `DATEVALUE`

Returns a date value from a string representation of a date or 
a datetime.

Accepts 1 argument: the date as a string or datetime.

```apex
FormulaEvaluator.evaluate('DATEVALUE("2020-01-01")'); // 2020-01-01 00:00:00
FormulaEvaluator.evaluate('DATEVALUE(NOW())'); // 2020-01-01 00:00:00
```

- `DATETIMEVALUE`

Returns a datetime value from a string representation of a date.

Accepts 1 argument: the date as a string.

```apex
FormulaEvaluator.evaluate('DATETIMEVALUE("2020-01-01")'); // 2020-01-01 00:00:00
```

- `TODAY`

Returns the current date.

Accepts no arguments.

```apex
FormulaEvaluator.evaluate('TODAY()'); // 2020-01-01
```

- `TIMEVALUE`

Returns a time value from a datetime or from a string representation of a datetime.

Accepts 1 argument: the datetime or string in datetime format to evaluate.

```apex
FormulaEvaluator.evaluate('TIMEVALUE(DATETIMEVALUE("2020-01-01 12:00:00"))'); // 12:00:00
FormulaEvaluator.evaluate('TIMEVALUE("17:30:45.125")'); // 17:30:45.125
```

- `TIMENOW`

Returns the current time.

Accepts no arguments.

```apex
FormulaEvaluator.evaluate('TIMENOW()'); // 12:00:00
```

- `ISOWEEK`

Returns the ISO week number of the year for a given date.

Accepts 1 argument: the date to evaluate.

```apex
FormulaEvaluator.evaluate('ISOWEEK(DATE(2020, 1, 1))'); // 1
```

- `ISOYEAR`

Returns the ISO year number for a given date.

Accepts 1 argument: the date to evaluate.

```apex
FormulaEvaluator.evaluate('ISOYEAR(DATE(2020, 1, 1))'); // 2020
```

- `YEAR`

Returns the year value of a provided date.

Accepts 1 argument: the date to evaluate.

```apex
FormulaEvaluator.evaluate('YEAR(DATE(2020, 1, 1))'); // 2020
```

- `MILLISECOND`

Returns the millisecond value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
FormulaEvaluator.evaluate('MILLISECOND(TIMEVALUE("12:00:00.123"))'); // 123
```

- `MINUTE`

Returns the minute value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
FormulaEvaluator.evaluate('MINUTE(TIMEVALUE("12:10:00"))'); // 10
```

- `SECOND`

REturns the second value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
FormulaEvaluator.evaluate('SECOND(TIMEVALUE("12:00:45"))'); //45
```

- `HOUR`

Returns the hour value of a provided time.

Accepts 1 argument: time to evaluate.

```apex
FormulaEvaluator.evaluate('HOUR(TIMEVALUE("12:00:00"))'); // 12
```

#### List Functions

- `TOLIST`

Extracts a list out of a particular field of a list of child SObjects related to the context.

Accepts 2 arguments: The child relationship merge field and the name of the field of the child to extract,
also as a merge field (not a string, so no quotes).

```apex
Account account = [SELECT (SELECT Id, Name FROM Contacts) FROM Account LIMIT 1];
Object result = FormulaEvaluator.evaluate('TOLIST(Contacts, Name)', account);
// ["John Doe", "Jane Doe"]
```

This can be combined with list operations to extract aggregate information out
of child records.

```apex
Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];
Object result = FormulaEvaluator.evaluate('AVERAGE(TOLIST(ChildAccounts, NumberOfEmployees))', parentAccountWithChildren); // 10
```

- `AVERAGE`

Returns the average of a list of numbers.

Accepts 1 argument: the list of numbers to evaluate.

```apex
FormulaEvaluator.evaluate('AVERAGE(LIST(1, 2, 3))'); // 2
```

#### Math Functions

- `ABS`

Returns the absolute value of a number.

Accepts 1 argument: the number to evaluate.

```apex
FormulaEvaluator.evaluate('ABS(-1)'); // 1
```

- `CEILING`

Returns the smallest integer greater than or equal to the specified number.

Accepts 1 argument: the number to evaluate.

```apex
FormulaEvaluator.evaluate('CEILING(1.5)'); // 2
```

- `FLOOR`

Returns the largest integer less than or equal to the specified number.

Accepts 1 argument: the number to evaluate.

```apex
FormulaEvaluator.evaluate('FLOOR(1.5)'); // 1
```

- `FROMUNIXTIME`

Returns the GMT Datetime from a Unix timestamp.

Accepts 1 argument: the Unix timestamp to evaluate.

```apex
FormulaEvaluator.evaluate('FROMUNIXTIME(1577836800)'); // 2020-01-01 00:00:00
```

- `MAX`

Returns the largest of one or more numbers.

Accepts either a list of numbers as a single argument, or multiple numerical arguments.

```apex
FormulaEvaluator.evaluate('MAX(LIST(1, 2, 3))'); // 3
FormulaEvaluator.evaluate('MAX(1, 2, 3)'); // 3
```

- `MIN`

Returns the smallest of one or more numbers.

At least one argument is required.

```apex
FormulaEvaluator.evaluate('MIN(1, 2, 3)'); // 1
```

- `ROUND`

Returns a rounded number. Optionally specify the number of decimal places to round to.

Accepts 1 or 2 arguments: the number to round and optionally the number of decimal places to round to.

```apex
FormulaEvaluator.evaluate('ROUND(1.5)'); // 2
FormulaEvaluator.evaluate('ROUND(1.5, 1)'); // 1.5
```

- `TRUNC`

Returns a truncated number. Optionally specify the number of decimal places to truncate to.

Accepts 1 or 2 arguments: the number to truncate and optionally the number of decimal places to truncate to.

```apex
FormulaEvaluator.evaluate('TRUNC(1.5)'); // 1
FormulaEvaluator.evaluate('TRUNC(1.5, 1)'); // 1.5
```

---

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

### Setup

Create a scratch org by running:

```bash
sfdx force:org:create -f config/project-scratch-def.json -a formula-evaluator -s
```

Then push the source to the scratch org:

```bash
sfdx force:source:push
```

#### Debugging

While debugging, you might find it helpful to see the generated AST for
a given expression.

The source code includes a `Visitor` implementation
whose sole purpose is to do this, `AstPrinter`. When enabled, it will
print the AST to the logs.

You can enable it by setting the `FormulaEvaluator.printAst` static variable to `true`.

```apex
FormulaEvaluator.printAst = true;
Object value = FormulaEvaluator.evaluate('AND(true, false, 1=1)');
// Outputs to the logs:
// (AND true false (= 1 1))
```

### Running tests

Run the tests with:

```bash
sfdx force:apex:test:run
```
