# Formula Evaluator

Allows you to evaluate formulas through Apex code.

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
