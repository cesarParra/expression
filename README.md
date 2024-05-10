<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/expression_logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/expression_logo_light.svg">
  <img alt="Expression Logo" src="assets/expression_logo_light.svg" width="400">
</picture>

Powerful formula-syntax evaluator for Apex and LWC.

</div>

# Features

* Supports all the most important operators and functions available in Salesforce formulas
* Support for lists and maps, including spread operator (`...`) support.
* Automatically understands relationships and can extract data from child records
* Comment support
* String interpolations
* Pre-built LWC component to evaluate Expressions in record pages and Experience Builder sites
* And much more!

# Examples

## Basic Math Operations

```apex
Object simpleMath = expression.Evaluator.run('(1 + 1) * 10');
System.debug(simpleMath); // 20

Object respectsPemdas = expression.Evaluator.run('1 + 1 * 10 + 50 * 20 / 100 + (20 * 20 /10)');
System.debug(respectsPemdas); // 61
```

## String Operations

```apex
Object simpleConcat = expression.Evaluator.run('"👋 hello " + "there!"');
System.debug(simpleConcat); // 👋 hello there!

Id recordId = '001Oy00000GkWjfIAF';
Object interpolation = expression.Evaluator.run('"👋 hello ${Name}"', recordId);
System.debug(interpolation); // 👋 hello Acme Inc.
```

## Advanced Operations

```apex
// Calculating if a year is a leap year
Id recordId = '001Oy00000GkWjfIAF';
Object result = expression.Evaluator.run('OR(\n' +
    '  MOD( YEAR( DATEVALUE(CreatedDate) ), 400 ) = 0, \n' +
    '  AND( \n' +
    '   MOD( YEAR( DATEVALUE(CreatedDate) ), 4 ) = 0,\n' +
    '    MOD( YEAR( DATEVALUE(CreatedDate) ), 100 ) != 0\n' +
    '  )\n' +
    ')', recordId);
System.debug(result); // true

// Determining the the region of an address
Id recordId = '001Oy00000GkWjfIAF';
Object result = expression.Evaluator.run('IF(ISBLANK(BillingState), "None",\n' +
    'IF(CONTAINS("AK:AZ:CA:HA:NV:NM:OR:UT:WA", BillingState), "West",\n' +
    'IF(CONTAINS("CO:ID:MT:KS:OK:TX:WY", BillingState), "Central",\n' +
    'IF(CONTAINS("CT:ME:MA:NH:NY:PA:RI:VT", BillingState), "East",\n' +
    'IF(CONTAINS("AL:AR:DC:DE:FL:GA:KY:LA:MD:MS:NC:NJ:SC:TN:VA:WV", BillingState), "South",\n' +
    'IF(CONTAINS("IL:IN:IA:MI:MN:MO:NE:ND:OH:SD:WI", BillingState), "North", "Other"))))))', recordId);
System.debug(result); // South
```

## Using Lists and Maps

```apex
Object listExample = expression.Evaluator.run('[1, 2, 3]');
System.debug(listExample); // (1 2 3)

Object mapExample = expression.Evaluator.run('{"key": "value"}');
System.debug(mapExample); // {key=value}
```

## Piping Complex Operations

```apex
Id recordId = '001Oy00000GkWjfIAF';
Object result = expression.Evaluator.run(
    'ChildAccounts ' +
        '-> WHERE(AnnualRevenue > 200) ' +
        '-> WHERE(NumberOfEmployees > 10) ' +
        '-> MAP(Name)',
    recordId);
System.debug(result); // (Acme Inc. Acme Subsidiary)
```

# Documentation

## Table of Contents

- Introduction
    - [Getting Started](https://cesarparra.github.io/expression/)
    - [Installation](https://cesarparra.github.io/expression/docs/installation)
    - [Try](https://cesarparra.github.io/expression/docs/try)
- Usage
    - [Evaluating Expressions](https://cesarparra.github.io/expression/docs/usage)
    - [Accessing Contextual Data](https://cesarparra.github.io/expression/docs/accessing-contextual-data)
    - [Configuring the evaluation](https://cesarparra.github.io/expression/docs/configuring-the-evaluation)
- Language Features
    - [Lists](https://cesarparra.github.io/expression/docs/lists)
    - [Maps](https://cesarparra.github.io/expression/docs/maps)
    - [Piping](https://cesarparra.github.io/expression/docs/piping)
    - [String Interpolation](https://cesarparra.github.io/expression/docs/string-interpolation)
    - [Querying Record Data](https://cesarparra.github.io/expression/docs/querying-record-data)
    - [Referencing Org Data](https://cesarparra.github.io/expression/docs/referencing-org-data)
    - [Comments](https://cesarparra.github.io/expression/docs/comments)
- Standard Library
    - [Operators](https://cesarparra.github.io/expression/docs/operators)
    - [Functions](https://cesarparra.github.io/expression/docs/functions)
- Advanced Usage
    - [Custom Functions](https://cesarparra.github.io/expression/docs/custom-functions)
    - [Apex Interoperability](https://cesarparra.github.io/expression/docs/apex-interoperability)
    - [Providing More Context To Your Expressions](https://cesarparra.github.io/expression/docs/more-context)
- Components
    - [Getting Started with Expression Components](https://cesarparra.github.io/expression/docs/components/getting-started)
    - [Accordion](https://cesarparra.github.io/expression/docs/components/accordion)
    - [Alert](https://cesarparra.github.io/expression/docs/components/alert)
    - [Avatar](https://cesarparra.github.io/expression/docs/components/avatar)
    - [Banner](https://cesarparra.github.io/expression/docs/components/banner)
    - [Button](https://cesarparra.github.io/expression/docs/components/button)
    - [Avatars (Stacked)](https://cesarparra.github.io/expression/docs/components/stacked-avatars)
    - [Features](https://cesarparra.github.io/expression/docs/components/features)
    - [Form Builder](https://cesarparra.github.io/expression/docs/components/form-builder)
    - [Formula](https://cesarparra.github.io/expression/docs/components/formula)
    - [Hero](https://cesarparra.github.io/expression/docs/components/hero)
    - [Input Text](https://cesarparra.github.io/expression/docs/components/input-text)
    - [Nav Bar](https://cesarparra.github.io/expression/docs/components/nav-bar)
    - [Logos](https://cesarparra.github.io/expression/docs/components/logos)
    - [People](https://cesarparra.github.io/expression/docs/components/people)
    - [Pricing Table](https://cesarparra.github.io/expression/docs/components/pricing-table)
    - [Stats](https://cesarparra.github.io/expression/docs/components/stats)
    - [Text Block](https://cesarparra.github.io/expression/docs/components/text-block)

For the full Expression language documentation,
please visit [cesarparra.github.io/expression/](https://cesarparra.github.io/expression/).

---

# Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## Setup

Create a scratch org by running:

```bash
sfdx force:org:create -f config/dev.json -a Expression --setdefaultusername
```

Push the source to the scratch org:

```bash
sfdx force:source:push
```

Assign the `Expression Admin` permission set to the default user:

```bash
sfdx force:user:permset:assign -n Expression_Admin
```

### Debugging

While debugging, you might find it helpful to see the generated AST for
a given expression.

The source code includes a `Visitor` implementation
whose sole purpose is to do this, `AstPrinter`. When enabled, it will
print the AST to the logs.

You can enable it by passing an `expression.Configuration` option to the `run`
method with the `printAst` option enabled :

```apex
expression.Configuration config = new expression.Configuration().printAst();
Object value = expression.Evaluator.run('AND(true, false, 1=1)', config);
// Outputs to the logs:
// (AND true false (= 1 1))
```

## Running tests

Run the tests with:

```bash
sfdx force:apex:test:run
```
