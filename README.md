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
    - [Button](https://cesarparra.github.io/expression/docs/components/button)
    - [Avatars (Stacked)](https://cesarparra.github.io/expression/docs/components/stacked-avatars)
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

### Features

The `Features` component allows you to display a list of features. It can be used
to display a list of features, benefits, etc.

Supports being placed in a community page.

#### Properties

- `Formula Expression` - The expression to evaluate. This expression should evaluate to a map with the following format:

##### Map Format

- `title` Optional - The title to display.
- `description` Optional - The description to display.
- `features` - List of features to display. Each feature should be a map with the following format:
    - `title` - The title of the feature.
    - `description` - The description of the feature.

```json
{
  "title": "<<String value or expression>>",
  "description": "<<String value or expression>>",
  "features": [
    {
      "title": "<<String value or expression>>",
      "description": "<<String value or expression>>"
    }
  ]
}
```

#### Properties

- `Formula Expression` - The expression to evaluate. This expression should evaluate to a String.

```json
"<<String value or expression>>"
```

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
