---
title: Functions
nextjs:
  metadata:
    title: Functions
    description: Functions overview.
---

## Logical Functions

- `AND`

Returns a TRUE response if all values are true; returns a FALSE response if one or more values are false.

Accepts multiple arguments, but must have at least 2.

```apex
expression.Evaluator.run('AND(true, true)'); // true
expression.Evaluator.run('AND(true, false, true)'); // false
```

- `IF`

Returns one value if a condition is true and another value if it's false.

Accepts 3 arguments: the condition, the value if true, and the value if false.

```apex
expression.Evaluator.run('IF(true, "Hello", "World")'); // "Hello"
expression.Evaluator.run('IF(false, "Hello", "World")'); // "World"
```

- `NOT`

Reverses the logical value of its argument.

```apex
expression.Evaluator.run('NOT(true)'); // false
```

- `OR`

Returns a TRUE response if any value is true; returns a FALSE response if all values are false.

Accepts any number of arguments.

```apex
expression.Evaluator.run('OR(true, false)'); // true
expression.Evaluator.run('OR(false, false)'); // false
```

- `BLANKVALUE`

Returns a specified value if the expression is blank (null value or empty string); otherwise, returns the result of the
expression.

Accepts 2 arguments: the expression and the value to return if the expression is blank.

```apex
expression.Evaluator.run('BLANKVALUE(null, "Hello")'); // "Hello"
expression.Evaluator.run('BLANKVALUE("World", "Hello")'); // "World"
```

- `ISBLANK`

Returns TRUE if the expression is blank (null value or empty string); otherwise, returns FALSE.

Accepts 1 argument: the expression to check.

```apex
expression.Evaluator.run('ISBLANK(null)'); // true
expression.Evaluator.run('ISBLANK("")'); // true
expression.Evaluator.run('ISBLANK("Hello")'); // false
```

- `CASE`

Compares a given expression to a set of values. If the expression matches a value, the corresponding value is returned,
otherwise the default value is returned.

Accepts any number of arguments where the first is the expression to evaluate, the last is the "else" case
and in between each pair of arguments is a value to compare against and the value to return if the expression matches.
Format: `CASE(expression,value1, result1, value2, result2,..., else_result)`

```apex
Account testAccount = new Account(Rating = 'Hot');
Object result = expression.Evaluator.run(
    'CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")',
    testAccount); // "🔥"
```

- `ISNUMBER`

Returns TRUE if the expression is a number; otherwise, returns FALSE.

Accepts 1 argument: the expression to check.

```apex
expression.Evaluator.run('ISNUMBER(1)'); // true
expression.Evaluator.run('ISNUMBER("Hello")'); // false
```

## String Functions

- `BEGINS`

Returns TRUE if the first character(s) in a text field match a given string.

Accepts 2 arguments: the text field and the string to match.

```apex
expression.Evaluator.run('BEGINS("Hello World", "Hello")'); // true
```

- `CONTAINS`

Returns TRUE if a text field contains a given string.

Accepts 2 arguments: the text field and the string to match.

```apex
    expression.Evaluator.run('CONTAINS("Hello World", "llo Wo")'); // true
```

- `LOWER`

Converts all letters in the specified text to lowercase.

Accepts 1 argument: the text to convert.

```apex
expression.Evaluator.run('LOWER("Hello World")'); // "hello world"
```

- `FIND`

Returns the starting position of one text string within another text string. If the text string is not found, FIND
returns a value -1.

Accepts either 2 or 3 arguments: the text to find, the text to search, and optionally the starting position.

```apex
expression.Evaluator.run('FIND("World", "Hello World")'); // 6
expression.Evaluator.run('FIND("World", "Hello World", 7)'); // -1
```

- `INITCAP`

Converts the first letter of each word in a text string to uppercase and converts all other letters to lowercase.

Accepts 1 argument: the text to convert.

```apex
expression.Evaluator.run('INITCAP("hello world")'); // "Hello World"
```

- `LEFT`

Returns the specified number of characters from the beginning of a text string.

Accepts 2 arguments: the text to evaluate and the number of characters to return.

```apex
expression.Evaluator.run('LEFT("Hello World", 5)'); // "Hello"
```

- `LEN`

Returns the number of characters in a text string.

Accepts 1 argument: the text to evaluate.

```apex
expression.Evaluator.run('LEN("Hello World")'); // 11
```

- `LIKE`

Returns TRUE if a text field matches a given pattern. The pattern can include regular characters and wildcard
characters.
The supported wildcard characters are the percent sign (%), which matches zero or more characters, and the
underscore (_),
which matches exactly one character.

Accepts 2 arguments: the text to evaluate and the pattern to match.

```apex
expression.Evaluator.run('LIKE("Hello World", "Hello%")'); // true
```

- `LPAD`

Returns a text value padded to the specified length with the specified set of characters.

Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
If the padding character is not specified, it defaults to a space.

```apex
expression.Evaluator.run('LPAD("Hello", 10)'); // "     Hello"
expression.Evaluator.run('LPAD("Hello", 10, "*")'); // "*****Hello"
```

- `RPAD`

Returns a text value padded to the specified length with the specified set of characters.

Accepts 2 or 3 arguments: the text to pad, the length to pad to, and optionally the padding character.
If the padding character is not specified, it defaults to a space.

```apex
expression.Evaluator.run('RPAD("Hello", 10)'); // "Hello     "
expression.Evaluator.run('RPAD("Hello", 10, "*")'); // "Hello*****"
```

- `REVERSE`

Returns a text value with the order of the characters reversed.

Accepts 1 argument: the text to reverse.

```apex
expression.Evaluator.run('REVERSE("Hello World")'); // "dlroW olleH"
```

- `SPLIT`

Returns a list that contains each substring of the String that is terminated
by the provided delimiter.

Accepts 2 arguments: the text to split and the delimiter.

```apex
expression.Evaluator.run('SPLIT("Hello World", " ")'); // ("Hello", "World")
```

- `MID`

Returns a specified number of characters from a text string starting at the position you specify up
to the number of characters you specify.

Note that the position is 1-based, not 0-based.

Accepts 3 arguments: the text to evaluate, the starting position, and the number of characters to return.

```apex
expression.Evaluator.run('MID("Hello World", 7, 5)'); // "World"
```

- `SUBSTRING`

Returns a specified number of characters from a text string starting at the position you specify.
Optionally, you can specify the number of characters to return.

Note that the position is 1-based, not 0-based.

Accepts 2 or 3 arguments: the text to evaluate and the starting position. Optionally, the number of characters to

```apex
expression.Evaluator.run('SUBSTRING("Hello World", 7)'); // "World"
expression.Evaluator.run('SUBSTRING("Hello World", 7, 5)'); // "World"
```

- `RIGHT`

Returns the specified number of characters from the end of a text string.

Accepts 2 arguments: the text to evaluate and the number of characters to return.

If the second argument is a negative number, it gets treated as a 0

```apex
expression.Evaluator.run('RIGHT("Hello World", 5)'); // "World"
expression.Evaluator.run('RIGHT("Hello World", -5)'); // ""
```

- `BR`

Inserts a line break in a string of text.

When no arguments are provided, it inserts a line break. When a number is provided, it inserts that number of line

⚠️ Note that the inserted line break depends on the call context based on
the [Request Quiddity](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm).
When called from
an Aura/LWC or Visualforce context it will insert a `<br>` tag, otherwise it will insert a newline character.

```apex
expression.Evaluator.run('BR()'); // "\n" or "<br>"
expression.Evaluator.run('BR(2)'); // "\n\n" or "<br><br>"
```

- `HYPERLINK`

Returns a text string of an HTML anchor tag that displays a hyperlink.

Accepts 2 or 3 arguments: the URL and the text to display. Optionally, the third argument is the target
of the link.

The target should be one of `_blank`, `_parent`, `_self`, or `_top`.

```apex
expression.Evaluator.run('HYPERLINK("https://www.google.com", "Google")'); // "<a href="https://www.google.com">Google</a>"
expression.Evaluator.run('HYPERLINK("https://www.google.com", "Google", "_blank")'); // "<a href="https://www.google.com" target="_blank">Google</a>"
```

- `SUBSTITUTE`

Substitutes new text for old text in a text string.

Accepts 3 arguments: the text to evaluate, the text to replace, and the text to replace it with.

```apex
expression.Evaluator.run('SUBSTITUTE("Hello World", "World", "Universe")'); // "Hello Universe"
```

- `TEXT`

Converts the received argument to a string.

Accepts 1 argument: the value to convert to a string.

```apex
expression.Evaluator.run('TEXT(1)'); // "1"
```

- `TRIM`

Removes the spaces and tabs from the beginning and end of a text string.

Accepts 1 argument: the text to trim.

```apex
expression.Evaluator.run('TRIM(" Hello World ")'); // "Hello World"
```

- `UPPER`

Converts all letters in the specified text to uppercase.

Accepts 1 argument: the text to convert.

```apex
expression.Evaluator.run('UPPER("Hello World")'); // "HELLO WORLD"
```

- `URLENCODE`

Encodes text and merge field values for use in URLs by replacing characters that are illegal in URLs, such as blank
spaces.

Accepts 1 argument: the text to encode.

```apex
expression.Evaluator.run('URLENCODE("Hello World")'); // "Hello+World"
```

- `VALUE`

Converts a text string that represents a number to a number.

Accepts 1 argument: the text to convert.

```apex
expression.Evaluator.run('VALUE("1")'); // 1
```

## Date and Time Functions

- `DATE`

Returns a date value from the provided year, month, and day values.

Accepts 3 arguments: the year, month, and day.

```apex
expression.Evaluator.run('DATE(2020, 1, 1)'); // 2020-01-01
```

- `DATETIME`

Returns a datetime value from the provided year, month, day, hour, minute, and second values.

Accepts 6 arguments: the year, month, day, hour, minute, and second.

```apex
expression.Evaluator.run('DATETIME(2020, 1, 1, 12, 0, 0)'); // 2020-01-01 12:00:00
```

- `ADDMONTHS`

Returns a date that is a specified number of months before or after a given date.

Accepts 2 arguments: the date and the number of months to add.

```apex
expression.Evaluator.run('ADDMONTHS(DATE(2020, 1, 1), 1)'); // 2020-02-01
```

- `DAY`

Returns the day of the month, a number from 1 to 31.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('DAY(DATE(2020, 1, 1))'); // 1
```

- `DAYOFYEAR`

Returns the day of the year, a number from 1 to 366.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('DAYOFYEAR(DATE(2020, 1, 1))'); // 1
```

- `NOW`

Returns the current Datetime in the GMT time zone.

Accepts no arguments.

```apex
expression.Evaluator.run('NOW()'); // 2020-01-01 00:00:00
```

- `DATEVALUE`

Returns a date value from a string representation of a date or
a datetime.

Accepts 1 argument: the date as a string or datetime.

```apex
expression.Evaluator.run('DATEVALUE("2020-01-01")'); // 2020-01-01
expression.Evaluator.run('DATEVALUE(NOW())'); // 2020-01-01
```

- `DATETIMEVALUE`

Returns a datetime value from a string representation of a date time.

Accepts 1 argument: the date time as a string.

```apex
expression.Evaluator.run('DATETIMEVALUE("2020-01-01 00:00:00")'); // 2020-01-01 00:00:00
```

- `DATETIMEFORMAT`

Formats a DateTime into a string using the provided format.

Accepts 2 arguments: the datetime to format and the format string.

```apex
expression.Evaluator.run('DATETIMEFORMAT(DATETIMEVALUE("2020-01-01 12:00:00"), "yyyy-MM-dd")'); // "2020-01-01"
```

- `DAYSBETWEEN`

Returns the number of days between two dates.

Accepts 2 arguments: the first date and the second date.

```apex
expression.Evaluator.run('DAYSBETWEEN(DATE(2020, 1, 1), DATE(2020, 1, 2))'); // 1
```

- `TODAY`

Returns the current date.

Accepts no arguments.

```apex
expression.Evaluator.run('TODAY()'); // 2020-01-01
```

- `DATETODATETIME`

Converts a Date to a Datetime.

Accepts 1 argument: the date to convert.

```apex
expression.Evaluator.run('DATETODATETIME(DATE(2020, 1, 1))'); // 2020-01-01 00:00:00
```

- `TIMEVALUE`

Returns a time value from a datetime or from a string representation of a datetime.

Accepts 1 argument: the datetime or string in datetime format to evaluate.

```apex
expression.Evaluator.run('TIMEVALUE(DATETIMEVALUE("2020-01-01 12:00:00"))'); // 12:00:00
expression.Evaluator.run('TIMEVALUE("17:30:45.125")'); // 17:30:45.125
```

- `TIMENOW`

Returns the current time.

Accepts no arguments.

```apex
expression.Evaluator.run('TIMENOW()'); // 12:00:00
```

- `ISOWEEK`

Returns the ISO week number of the year for a given date.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('ISOWEEK(DATE(2020, 1, 1))'); // 1
```

- `ISOYEAR`

Returns the ISO year number for a given date.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('ISOYEAR(DATE(2020, 1, 1))'); // 2020
```

- `YEAR`

Returns the year value of a provided date.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('YEAR(DATE(2020, 1, 1))'); // 2020
```

- `MILLISECOND`

Returns the millisecond value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
expression.Evaluator.run('MILLISECOND(TIMEVALUE("12:00:00.123"))'); // 123
```

- `SECOND`

Returns the second value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
expression.Evaluator.run('SECOND(TIMEVALUE("12:00:45"))'); //45
```

- `MINUTE`

Returns the minute value of a provided time.

Accepts 1 argument: the time to evaluate.

```apex
expression.Evaluator.run('MINUTE(TIMEVALUE("12:10:00"))'); // 10
```

- `HOUR`

Returns the hour value of a provided time.

Accepts 1 argument: time to evaluate.

```apex
expression.Evaluator.run('HOUR(TIMEVALUE("12:00:00"))'); // 12
```

- `UNIXTIMESTAMP`

Returns the number of seconds since 1 Jan 1970 for the given date or datetime,
or number of seconds in the day for a time.

Values are returned in the GMT time zone.

Accepts 1 argument: the date, datetime, or time to evaluate.

```apex
expression.Evaluator.run('UNIXTIMESTAMP(DATE(2020, 1, 1))'); // 1577836800
expression.Evaluator.run('UNIXTIMESTAMP(DATETIMEVALUE("2020-01-01 12:00:00"))'); // 1577880000
expression.Evaluator.run('UNIXTIMESTAMP(TIMEVALUE("12:00:00"))'); // 43200
```

- `WEEKDAY`

Returns the day of the week for a given date.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('WEEKDAY(DATE(2020, 1, 1))'); // 2
```

- `FORMATDURATION`

Calculates the difference between 2 Times or 2 DateTimes
and formats it as "HH:MM:SS".

Accepts 2 arguments: either 2 Times or 2 DateTimes.

Note that the order of the argument is not important, the
function will always return a positive duration.

```apex
expression.Evaluator.run('FORMATDURATION(TIMEVALUE("12:00:00"), TIMEVALUE("12:00:01"))'); // "00:00:01"
expression.Evaluator.run('FORMATDURATION(DATETIMEVALUE("2015-01-01 00:00:00"), DATETIMEVALUE("2015-01-02 00:00:00"))'); // "24:00:00"
```

- `MONTH`

Returns the month, a number between 1 and 12 (December) in number format of a given date.

Accepts 1 argument: the date to evaluate.

```apex
expression.Evaluator.run('MONTH(DATE(2020, 1, 1))'); // 1
```

## List Functions

- `APPEND`

Appends an element to a list.

Accepts 2 arguments: the list to append to and the element to append.

```apex
expression.Evaluator.run('APPEND([1, 2, 3], 4)'); // (1, 2, 3, 4)
```

- `ANY`

Returns true if any element in the list matches the given expression.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('ANY([1, 2, 3], $current = 2)'); // true
```

- `AT`

Returns the element at the specified index. If the list is empty or the
index is out of bounds, this function will return null.

Accepts 2 arguments: the list to evaluate and the index to return.

```apex
expression.Evaluator.run('AT([1, 2, 3], 1)'); // 2
```

- `FIRST`

Returns the first element of a list.

> Note: If the list is empty, this function will return null.

Accepts 1 argument: the list to evaluate.

```apex
expression.Evaluator.run('FIRST([1, 2, 3])'); // 1
```

- `DISTINCT`

Returns a list of unique values.

Accepts 1 argument: the list to evaluate.

```apex
expression.Evaluator.run('DISTINCT([1, 2, 3, 1, 2, 3])'); // (1, 2, 3)
```

- `FOLLOWEDBY`

Appends a list to another list.

Accepts 2 arguments: the list to append to and the list to append.

```apex
expression.Evaluator.run('FOLLOWEDBY([1, 2, 3], [4, 5, 6])'); // (1, 2, 3, 4, 5, 6)
```

- `FLATTEN`

Flattens a list of lists into a single list.

Accepts 1 argument: the list of lists to flatten.

```apex
expression.Evaluator.run('FLATTEN([[1, 2], [3, 4], [5, 6]])'); // (1, 2, 3, 4, 5, 6)
```

- `JOIN`

Joins a list of values into a string using the specified delimiter.

Accepts 2 arguments: the list to join and the delimiter.

```apex
expression.Evaluator.run('JOIN([1, 2, 3], ", ")'); // "1, 2, 3"
```

- `LAST`

Returns the last element of a list.

> Note: If the list is empty, this function will return null.

Accepts 1 argument: the list to evaluate.

```apex
expression.Evaluator.run('LAST([1, 2, 3])'); // 3
```

- `LASTWHERE`

Returns the last element of a list that matches the given expression or null
if the list is empty or no element matches the expression.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('LASTWHERE([1, 2, 3], $current > 2)'); // 3
```

- `CONTAINS`

Returns true if the list contains the given value.

Accepts 2 arguments: the list to evaluate and the value to check.

```apex
expression.Evaluator.run('CONTAINS([1, 2, 3], 2)'); // true
```

- `EVERY`

Returns true if every element in the list matches the given expression.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('EVERY([1, 2, 3], $current > 0)'); // true
```

- `EXPAND`

Expands each element of a list into zero or more elements, resulting from the
evaluation of the given expression.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate. The expression
must return a list.

```apex
expression.Evaluator.run('EXPAND([1, 2, 3], LIST($current, $current + 1))'); // (1, 2, 2, 3, 3, 4)
```

- `FIRSTWHERE`

Returns the first element of a list that matches the given expression or null
if the list is empty or no element matches the expression.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('FIRSTWHERE([1, 2, 3], $current > 2)'); // 3
```

- `MAP`

Maps to a list using the first argument as the context and the second argument as the expression to evaluate.

Accepts 2 arguments: List of objects and an expression to evaluate.

> In the inner expression, you have access to 3 special variables: `$index` (the index of the current
> record in the list), `$current` (the current item being iterated over), and `$total` (the total number
> of items in the list).

```apex
Object result = expression.Evaluator.run('MAP(["a", "b", "c"], UPPER($current))'); // ["A", "B", "C"]
```

To work with child records, you can specify the child relationship name as the first argument, and then the expression
to evaluate on each
child item as the second argument.

> When referencing child data through the record Id endpoint, the framework will take care of any necessary
> subqueries, so only one SOQL query is consumed.

This expression can be anything, something as simple as extracting a single field:

```apex
Object result = expression.Evaluator.run('MAP(ChildAccounts, Name)', parentAccountRecordOrId);
Assert.areEqual('[ACME Child, Another Child]', result);
```

To as complex as building a map with multiple fields that even references the parent record:

```apex
Object result = expression.Evaluator.run('MAP(ChildAccounts, { "Number": $index + 1, "Name": Name, "Parent Name": Parent.Name })', parentAccount);
// [{ "Number": 1, "Name": "ACME Child", "Parent Name": "ACME" }]
```

This can be combined with list operations to extract aggregate information out
of child records.

```apex
Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];
Object result = expression.Evaluator.run('AVERAGE(MAP(ChildAccounts, NumberOfEmployees))', parentAccountWithChildren); // 10
```

- `RANGE`

Returns a list of numbers from the start to the end, inclusive.

Accepts 2 arguments: the start and end numbers.

```apex
expression.Evaluator.run('RANGE(1, 3)'); // (1, 2, 3)
```

- `REDUCE`

Reduces a list to a single value using the first argument as the context, the second argument as the expression to
evaluate,
and the third argument as the initial value.

Accepts 3 arguments: List of objects, an expression to evaluate, and the initial value.

Provides 2 special variables in the inner expression:

- `$current` - the current item being iterated over
- `$accumulator` - the current value of the accumulator that will be returned

```apex
Object result = expression.Evaluator.run('REDUCE([1, 2, 3], $accumulator + $current, 0)'); // 6
```

This function can be used to build complex objects from a list of data. For example, to aggregate
the number of employees and revenue for an account based on the values from its children, an expression
as follows can be used:

```apex
Id parentAccountId = '001000000000000AAA';
String formula = 'REDUCE(ChildAccounts, ' +
    '{"employees": NumberOfEmployees + GET($accumulator, "employees"), "revenue": AnnualRevenue + GET($accumulator, "revenue")}, ' +
    '{"employees": 0, "revenue": 0}' +
    ')';
Object result = Evaluator.run(formula, parentAccountId);
// { "employees": 10, "revenue": 1000000 }
```

- `REVERSE`

Reverses a list.

Accepts 1 argument: the list to reverse.

```apex
expression.Evaluator.run('REVERSE([1, 2, 3])'); // (3, 2, 1)
```

- `SORT`

Sorts a list.

Accepts at least one argument: the list to sort.
When sorting a list of Maps or a list of SObjects,
three additional arguments can be provided: the field to sort by, the sort direction, and
and the position of nulls (nulls first or nulls last).

The field to sort can either be a field name as a merge field (field name without quotes), or an expression that
evaluates to a string
representing the field name. Merge fields are only supported when sorting SObjects and are useful to get the framework
to automatically
query the field for you.

> The merge field must be a field on the SObject being sorted itself, not a relationship field.

The sort direction can either be the literal string (requires quotes) `ASC` or `DESC`.
The position of nulls can either be the literal string (requires quotes) `NULLS_FIRST` or `NULLS_LAST`.

```apex
expression.Evaluator.run('SORT([3, 2, 1])'); // (1, 2, 3)
expression.Evaluator.run('SORT([{ "a": 3 }, { "a": 2 }, { "a": 1 }], "a")'); // ({ "a": 1 }, { "a": 2 }, { "a": 3 })
expression.Evaluator.run('SORT([{ "a": 3 }, { "a": 2 }, { "a": 1 }], "a", "DESC")'); // ({ "a": 3 }, { "a": 2 }, { "a": 1 })
expression.Evaluator.run('QUERY(Account["Name"]) -> SORT("Name")'); // ({"Name": "ACME"}, {"Name": "Another Account"})
expression.Evaluator.run('SORT(ChildAccounts, NumberOfEmployees, "asc")', parentAccount.Id); // ({"NumberOfEmployees": 1}, {"NumberOfEmployees": 2})
expression.Evaluator.run('SORT(ChildAccounts, NumberOfEmployees, "asc", "NULLS_LAST")', parentAccount.Id); // ({"NumberOfEmployees": 1}, {"NumberOfEmployees": 2}, {"NumberOfEmployees": null})
```

- `SKIP`

Skips the first N elements of a list.

Accepts 2 arguments: the list to skip and the number of elements to skip.

```apex
expression.Evaluator.run('SKIP([1, 2, 3], 2)'); // (3)
```

- `SKIPWHILE`

Skips elements of a list while the given expression evaluates to true.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('SKIPWHILE([1, 2, 3], $current < 3)'); // (3)
```

- `SUM`

Returns the sum of a list of numbers.

Accepts 1 argument: the list of numbers to evaluate.

```apex
expression.Evaluator.run('SUM([1, 2, 3])'); // 6
```

- `TAKE`

Returns the first N elements of a list.

Accepts 2 arguments: the list to take from and the number of elements to take.

```apex
expression.Evaluator.run('TAKE([1, 2, 3], 2)'); // (1, 2)
```

- `TAKEWHILE`

Returns elements of a list while the given expression evaluates to true.

Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).

Accepts 2 arguments: the list to evaluate and the expression to evaluate.

```apex
expression.Evaluator.run('TAKEWHILE([1, 2, 3], $current < 3)'); // (1, 2)
```

- `WHERE`

Filters a list using the first argument as the context and the second argument as the expression to evaluate.

Accepts 2 arguments: List of objects and an expression to evaluate.

> In the inner expression, you have access to 3 special variables: `$index` (the index of the current
> record in the list), `$current` (the current item being iterated over), and `$total` (the total number
> of items in the list).

```apex
Object result = expression.Evaluator.run('WHERE([1, 2, 3], $current > 1)'); // [2, 3]
```

Everything that applies to `MAP` also applies here as well, including the ability to reference child data.

- `AVERAGE`

Returns the average given a list of numbers.

Accepts 1 argument: the list of numbers to evaluate.

```apex
expression.Evaluator.run('AVERAGE(LIST(1, 2, 3))'); // 2
```

- `MAX` and `MIN`

## Map Functions

- `KEYS`

Returns a list of keys in a map.

Accepts 1 argument: the map to evaluate.

```apex
expression.Evaluator.run('KEYS({ "a": 1, "b": 2, "c": 3 })'); // ["a", "b", "c"]
```

- `GET`

Returns the value of a key in a map or the field in an SObject.

Accepts 2 arguments: the map or SObject to evaluate and the key to get.

```apex
expression.Evaluator.run('GET({ "a": 1, "b": 2, "c": 3 }, "b")'); // 2
```

- `VALUES`

Returns a list of values in a map.

Accepts 1 argument: the map to evaluate.

```apex
expression.Evaluator.run('VALUES({ "a": 1, "b": 2, "c": 3 })'); // [1, 2, 3]
```

- `PUT`

Adds a key/value pair to a map.

Accepts 3 arguments: the map to add to, the key to add, and the value to add.

```apex
expression.Evaluator.run('PUT({ "a": 1, "b": 2, "c": 3 }, "d", 4)'); // { "a": 1, "b": 2, "c": 3, "d": 4 }
```

## Lists and Maps Functions

Functions that work with both lists and maps.

- `SIZE`

Returns the number of elements in a list or map.

Accepts 1 argument: the list or map to evaluate.

```apex
expression.Evaluator.run('SIZE(LIST(1, 2, 3))'); // 3
expression.Evaluator.run('SIZE({ "a": 1, "b": 2, "c": 3 })'); // 3
```

- `ISEMPTY`

Returns true if the list or map is empty.

Accepts 1 argument: the list or map to evaluate.

```apex
expression.Evaluator.run('ISEMPTY(LIST(1, 2, 3))'); // false
expression.Evaluator.run('ISEMPTY({ "a": 1, "b": 2, "c": 3 })'); // false
expression.Evaluator.run('ISEMPTY(LIST())'); // true
expression.Evaluator.run('ISEMPTY({})'); // true
```

## Math Functions

- `ABS`

Returns the absolute value of a number.

Accepts 1 argument: the number to evaluate.

```apex
expression.Evaluator.run('ABS(-1)'); // 1
```

- `CEILING`

Returns the smallest integer greater than or equal to the specified number.

Accepts 1 argument: the number to evaluate.

```apex
expression.Evaluator.run('CEILING(1.5)'); // 2
```

- `FLOOR`

Returns the largest integer less than or equal to the specified number.

Accepts 1 argument: the number to evaluate.

```apex
expression.Evaluator.run('FLOOR(1.5)'); // 1
```

- `FROMUNIXTIME`

Returns the GMT Datetime from a Unix timestamp.

Accepts 1 argument: the Unix timestamp to evaluate.

```apex
expression.Evaluator.run('FROMUNIXTIME(1577836800)'); // 2020-01-01 00:00:00
```

- `MAX`

Returns the largest of one or more numbers.

Accepts either a list of numbers as a single argument, or multiple numerical arguments.

```apex
expression.Evaluator.run('MAX(LIST(1, 2, 3))'); // 3
expression.Evaluator.run('MAX(1, 2, 3)'); // 3
```

- `MIN`

Returns the smallest of one or more numbers.

Accepts either a list of numbers as a single argument, or multiple numerical arguments.

```apex
expression.Evaluator.run('MIN(LIST(1, 2, 3))'); // 1
expression.Evaluator.run('MIN(1, 2, 3)'); // 1
```

- `MOD`

Returns the remainder of one number divided by another.

Accepts 2 arguments: the dividend and the divisor.

```apex
expression.Evaluator.run('MOD(5, 2)'); // 1
```

- `ROUND`

Returns a rounded number. Optionally specify the number of decimal places to round to.

Accepts 1 or 2 arguments: the number to round and optionally the number of decimal places to round to.

```apex
expression.Evaluator.run('ROUND(1.5)'); // 2
expression.Evaluator.run('ROUND(1.5, 1)'); // 1.5
```

- `TRUNC`

Returns a truncated number. Optionally specify the number of decimal places to truncate to.

Accepts 1 or 2 arguments: the number to truncate and optionally the number of decimal places to truncate to.

```apex
expression.Evaluator.run('TRUNC(1.5)'); // 1
expression.Evaluator.run('TRUNC(1.5, 1)'); // 1.5
```

## Data Functions

- `TRANSFORM`

Transforms any input using the provided expression.

Provides a special variable `$source` in the inner expression that contains the original input.

Accepts 2 arguments: the input to transform and the expression to evaluate.

```apex
expression.Evaluator.run('TRANSFORM("Hello World", UPPER($source))'); // "HELLO WORLD"
```

- `LET`

Allows you to define custom variables that can be used in the expression.

Accepts 2 arguments: a map of variables to define and the expression to evaluate.

The map keys should be the variable names prefixed with `$`.

```apex
expression.Evaluator.run('LET({ "$a": 1, "$b": 2 }, $a + $b)'); // 3
```

- `RAWQUERY`

Executes a raw SOQL query and returns the results as a list of SObjects.

Accepts 1 argument: the SOQL query to execute.

```apex
expression.Evaluator.run('RAWQUERY("SELECT Id, Name FROM Account")'); // [{ "Id": "001000000000000AAA", "Name": "ACME" }, { "Id": "001000000000000AAB", "Name": "Another Account" }]
```

## Location Functions

- `LOCATION`

Returns a location object from the provided latitude and longitude.

Accepts 2 arguments: the latitude and longitude.

```apex
expression.Evaluator.run('LOCATION(37.7749, 122.4194)'); // { "latitude": 37.7749, "longitude": 122.4194 }
```

- `DISTANCE`

Returns the distance between two locations in the specified unit.

Accepts 3 arguments: the first location, the second location, and the unit (either
`"mi"` or `"km"`).

```apex
expression.Evaluator.run('DISTANCE(LOCATION(37.7749, 122.4194), LOCATION(40.7128, 74.0060), "mi")'); // 2565.6985207767134
```

---
