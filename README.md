# Formula Evaluator

Allows you to evaluate formula-like syntax through Apex code.

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

```apex
Account account = new Account(Name = 'ACME');
Object result = FormulaEvaluator.evaluate('Name', account);
Assert.areEqual('ACME', result);
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

At least one argument is required.

```apex
FormulaEvaluator.evaluate('MAX(1, 2, 3)'); // 3
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
