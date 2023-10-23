export const data = [
  {
    "category": "Collection",
    "values": [
      {
        "name": "ANY",
        "autoCompleteValue": "ANY(",
        "description": "Returns true if any element in the list matches the given expression.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "ANY([1, 2, 3], $current = 2) // true"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "APPEND",
        "autoCompleteValue": "APPEND(",
        "description": "Appends an item to a list.<br/>Accepts 2 arguments: the list and the item to append.",
        "examples": [
          "APPEND(LIST(1, 2, 3), 4) // [1, 2, 3, 4]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "AT",
        "autoCompleteValue": "AT(",
        "description": "Returns the element at the specified index. If the list is empty or the<br/>index is out of bounds, this function will return null.<br/>Accepts 2 arguments: the list to evaluate and the index to return.",
        "examples": [
          "AT([1, 2, 3], 1) // 2"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "AVERAGE",
        "autoCompleteValue": "AVERAGE(",
        "description": "Returns the average given a list of numbers.<br/>Accepts 1 argument: the list of numbers to evaluate.",
        "examples": [
          "AVERAGE(LIST(1, 2, 3))"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "DISTINCT",
        "autoCompleteValue": "DISTINCT(",
        "description": "Returns a list of unique values.",
        "examples": [
          "DISTINCT(LIST(1, 2, 3, 1, 2, 3)) // [1, 2, 3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "EVERY",
        "autoCompleteValue": "EVERY(",
        "description": "Returns true if every element in the list matches the given expression.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "EVERY([1, 2, 3], $current > 0) // true"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "EXPAND",
        "autoCompleteValue": "EXPAND(",
        "description": "Expands each element of a list into zero or more elements, resulting from the<br/>evaluation of the given expression.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate. The expression<br/>must return a list.",
        "examples": [
          "EXPAND([1, 2, 3], LIST($current, $current + 1)) // [1, 2, 2, 3, 3, 4]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FIRST",
        "autoCompleteValue": "FIRST(",
        "description": "Returns the first element in a list.<br/>Accepts 1 argument: the list to evaluate.",
        "examples": [
          "FIRST(LIST(1, 2, 3)) // 1"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FIRSTWHERE",
        "autoCompleteValue": "FIRSTWHERE(",
        "description": "Returns the first element of a list that matches the given expression or null<br/>if the list is empty or no element matches the expression.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "FIRSTWHERE([1, 2, 3], $current > 2) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FOLLOWEDBY",
        "autoCompleteValue": "FOLLOWEDBY(",
        "description": "Appends a list to another list.<br/>Accepts 2 arguments: the list to append to and the list to append.",
        "examples": [
          "FOLLOWEDBY([1, 2, 3], [4, 5, 6])"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "GET",
        "autoCompleteValue": "GET(",
        "description": "Returns the value of a key in a map or the field in an SObject.<br/>Accepts 2 arguments: the map or SObject to evaluate and the key to get.",
        "examples": [
          "GET(MAP('a' => 1, 'b' => 2, 'c' => 3), 'a') // 1"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "ISEMPTY",
        "autoCompleteValue": "ISEMPTY(",
        "description": "Returns true if the list or map is empty.<br/>Accepts 1 argument: the list or map to evaluate.",
        "examples": [
          "ISEMPTY(LIST(1, 2, 3)) // false"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "JOIN",
        "autoCompleteValue": "JOIN(",
        "description": "Joins a list of values into a string using the specified delimiter.<br/>Accepts 2 arguments: the list to join and the delimiter.",
        "examples": [
          "JOIN([1, 2, 3], \", \")"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "KEYS",
        "autoCompleteValue": "KEYS(",
        "description": "Returns a list of keys in a map.",
        "examples": [
          "KEYS(MAP('a' => 1, 'b' => 2, 'c' => 3)) // ['a', 'b', 'c']"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "LAST",
        "autoCompleteValue": "LAST(",
        "description": "Returns the last element in a list.<br/>Accepts 1 argument: the list to evaluate.",
        "examples": [
          "LAST(LIST(1, 2, 3)) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "LASTWHERE",
        "autoCompleteValue": "LASTWHERE(",
        "description": "Returns the last element of a list that matches the given expression or null<br/>if the list is empty or no element matches the expression.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "LASTWHERE([1, 2, 3], $current > 2) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "LIST",
        "autoCompleteValue": "LIST(",
        "description": "Creates a list using the received arguments as the values.",
        "examples": [
          "LIST(1, 2, 3, ...LIST(4, 5, 6))"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "MAP",
        "autoCompleteValue": "MAP(",
        "description": "Maps to a list using the first argument as the context and the second argument as the expression to evaluate.<br/>Accepts 2 arguments: List of objects and an expression to evaluate.",
        "examples": [
          "MAP([\"a\", \"b\", \"c\"], UPPER($current))"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "PUT",
        "autoCompleteValue": "PUT(",
        "description": "Adds a key/value pair to a map.<br/>Accepts 3 arguments: the map to add to, the key to add, and the value to add.",
        "examples": [
          "PUT({ \"a\": 1, \"b\": 2, \"c\": 3 }, \"d\", 4) // { \"a\": 1, \"b\": 2, \"c\": 3, \"d\": 4 }"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "RANGE",
        "autoCompleteValue": "RANGE(",
        "description": "Returns a list of numbers from the start to the end, inclusive.<br/>Accepts 2 arguments: the start and end numbers.",
        "examples": [
          "RANGE(1, 3) // [1, 2, 3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "REDUCE",
        "autoCompleteValue": "REDUCE(",
        "description": "Reduces a list to a single value using the first argument as the context, the second argument as the expression to evaluate,<br/>and the third argument as the initial value.<br/>Accepts 3 arguments: List of objects, an expression to evaluate, and the initial value.",
        "examples": [
          "REDUCE([1, 2, 3], $accumulator + $current, 0) // 6"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SIZE",
        "autoCompleteValue": "SIZE(",
        "description": "Returns the number of elements in a list or map.<br/>Accepts 1 argument: the list or map to evaluate.",
        "examples": [
          "SIZE(LIST(1, 2, 3)) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SKIP",
        "autoCompleteValue": "SKIP(",
        "description": "Skips the first N elements of a list.<br/>Accepts 2 arguments: the list to skip and the number of elements to skip.",
        "examples": [
          "SKIP([1, 2, 3], 2) // [3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SKIPWHILE",
        "autoCompleteValue": "SKIPWHILE(",
        "description": "Skips elements of a list while the given expression evaluates to true.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "SKIPWHILE([1, 2, 3], $current < 3) // [3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SORT",
        "autoCompleteValue": "SORT(",
        "description": "Sorts a list.<br/>Accepts at least one argument: the list to sort.<br/>When sorting a list of Maps or a list of SObjects,<br/>two additional arguments can be provided: the field to sort by and the sort direction.<br/>The field to sort can either be a field name as a merge field (field name without quotes), or an expression that evaluates to a string<br/>representing the field name. Merge fields are only supported when sorting SObjects and are useful to get the framework to automatically<br/>query the field for you.<br/>Note: The merge field must be a field on the SObject being sorted itself, not a relationship field.<br/>The sort direction can either be the literal string (requires quotes) `ASC` or `DESC`.",
        "examples": [
          "SORT([{ \"a\": 3 }, { \"a\": 2 }, { \"a\": 1 }], \"a\", \"DESC\") // [{ \"a\": 3 }, { \"a\": 2 }, { \"a\": 1 }]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SUM",
        "autoCompleteValue": "SUM(",
        "description": "Returns the sum of a list of numbers.<br/>Accepts 1 argument: the list of numbers to evaluate.",
        "examples": [
          "SUM([1, 2, 3]) // 6"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "TAKE",
        "autoCompleteValue": "TAKE(",
        "description": "Returns the first N elements of a list.<br/>Accepts 2 arguments: the list to take from and the number of elements to take.",
        "examples": [
          "TAKE([1, 2, 3], 2) // [1, 2]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "TAKEWHILE",
        "autoCompleteValue": "TAKEWHILE(",
        "description": "Returns elements of a list while the given expression evaluates to true.<br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "TAKEWHILE([1, 2, 3], $current < 3)"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "VALUES",
        "autoCompleteValue": "VALUES(",
        "description": "Returns a list of values in a map.",
        "examples": [
          "VALUES(MAP('a' => 1, 'b' => 2, 'c' => 3)) // [1, 2, 3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "WHERE",
        "autoCompleteValue": "WHERE(",
        "description": "Filters a list using the first argument as the context and the second argument as the expression to evaluate.<br/>Accepts 2 arguments: List of objects and an expression to evaluate.",
        "examples": [
          "WHERE([1, 2, 3], $current > 1)"
        ],
        "icon": "utility:justify_text"
      }
    ]
  },
  {
    "category": "Data",
    "values": [
      {
        "name": "FETCH",
        "autoCompleteValue": "FETCH(",
        "description": "Allows you to query data from the database. This is useful<br/>when the data you want to use is not provided as part of the context.<br/>TTakes 2 arguments: a string with the `SObjectName` you wish to extract data from,<br/>and a list of strings with the fields you wish to extract. This will query all the records of the given<br/>type and return a list of `SObjects` with the data.<br/>Note that when using this function, the automatic context resolution is not performed, so you need to<br/>explicitly specify all fields you wish to reference in the formula.",
        "examples": [
          "FETCH(\"Account\", [\"Id\", \"Name\"])"
        ],
        "icon": "utility:data_mapping"
      },
      {
        "name": "LET",
        "autoCompleteValue": "LET(",
        "description": "Allows you to define custom variables that can be used in the expression.<br/>Accepts 2 arguments: a map of variables to define and the expression to evaluate.<br/>The map keys should be the variable names prefixed with `$`.",
        "examples": [
          "LET({ \"$a\": 1, \"$b\": 2 }, $a + $b) // 3"
        ],
        "icon": "utility:data_mapping"
      },
      {
        "name": "TRANSFORM",
        "autoCompleteValue": "TRANSFORM(",
        "description": "Transforms any input using the provided expression.<br/>Provides a special variable `$source` in the inner expression that contains the original input.<br/>Accepts 2 arguments: the input to transform and the expression to evaluate.",
        "examples": [
          "TRANSFORM(\"Hello World\", UPPER($source)) // \"HELLO WORLD\""
        ],
        "icon": "utility:data_mapping"
      }
    ]
  },
  {
    "category": "Date and Time",
    "values": [
      {
        "name": "ADDMONTHS",
        "autoCompleteValue": "ADDMONTHS(",
        "description": "Returns a date that is a specified number of months before or after a given date.<br/>Accepts 2 arguments: the date and the number of months to add.",
        "examples": [
          "ADDMONTHS(DATE(2020, 1, 1), 1) // 2020-02-01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DATE",
        "autoCompleteValue": "DATE(",
        "description": "Returns a date value from the provided year, month, and day values.<br/>Accepts 3 arguments: the year, month, and day.",
        "examples": [
          "DATE(2020, 1, 1) // 2020-01-01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DATETIMEFORMAT",
        "autoCompleteValue": "DATETIMEFORMAT(",
        "description": "Formats a DateTime into a string using the provided format.<br/>Accepts 2 arguments: the DateTime to format and the format string.",
        "examples": [
          "DATETIMEFORMAT(DATETIMEVALUE(\"2020-01-01 12:00:00\"), \"yyyy-MM-dd\") // 2020-01-01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DATETIMEVALUE",
        "autoCompleteValue": "DATETIMEVALUE(",
        "description": "Returns a datetime value from a string representation of a date.<br/>Accepts 1 argument: the date as a string.",
        "examples": [
          "DATETIMEVALUE(\"2020-01-01\") // 2020-01-01 00:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DATETODATETIME",
        "autoCompleteValue": "DATETODATETIME(",
        "description": "Converts a Date to a Datetime.<br/>Accepts 1 argument: the Date to convert.",
        "examples": [
          "DATETODATETIME(DATE(2020, 1, 1)) // 2020-01-01 00:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DATEVALUE",
        "autoCompleteValue": "DATEVALUE(",
        "description": "Returns a date value from a string representation of a date or a datetime.<br/>Accepts 1 argument: the date as a string or datetime.",
        "examples": [
          "DATEVALUE(\"2020-01-01\") // 2020-01-01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DAY",
        "autoCompleteValue": "DAY(",
        "description": "Returns the day of the month, a number from 1 to 31.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "DAY(DATE(2020, 1, 1)) // 1"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DAYOFYEAR",
        "autoCompleteValue": "DAYOFYEAR(",
        "description": "Returns the day of the year, a number from 1 to 366.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "DAYOFYEAR(DATE(2020, 1, 1)) // 1"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "DAYSBETWEEN",
        "autoCompleteValue": "DAYSBETWEEN(",
        "description": "Returns the number of days between two dates.<br/>Accepts 2 arguments: the first date and the second date.",
        "examples": [
          "DAYSBETWEEN(DATE(2020, 1, 1), DATE(2020, 1, 2)) // 1"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "FORMATDURATION",
        "autoCompleteValue": "FORMATDURATION(",
        "description": "Calculates the difference between 2 Times or 2 DateTimes<br/>and formats it as \"HH:MM:SS\".<br/>Accepts 2 arguments: either 2 Times or 2 DateTimes.<br/>Note that the order of the argument is not important, the<br/>function will always return a positive duration.",
        "examples": [
          "FORMATDURATION(TIMEVALUE(\"12:00:00\"), TIMEVALUE(\"12:00:01\")) // 00:00:01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "FROMUNIXTIME",
        "autoCompleteValue": "FROMUNIXTIME(",
        "description": "Returns the GMT Datetime from a Unix timestamp.<br/>Accepts 1 argument: the Unix timestamp to evaluate.",
        "examples": [
          "FROMUNIXTIME(1577836800) // 2020-01-01 00:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "HOUR",
        "autoCompleteValue": "HOUR(",
        "description": "Returns the hour value of a provided time.<br/>Accepts 1 argument: the time to evaluate.",
        "examples": [
          "HOUR(TIMEVALUE(\"12:00:00\")) // 12"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "ISOWEEK",
        "autoCompleteValue": "ISOWEEK(",
        "description": "Returns the ISO week number of the year for a given date.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "ISOWEEK(DATE(2020, 1, 1)) // 1"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "ISOYEAR",
        "autoCompleteValue": "ISOYEAR(",
        "description": "Returns the ISO year number for a given date.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "ISOYEAR(DATE(2020, 1, 1)) // 2020"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "MILLISECOND",
        "autoCompleteValue": "MILLISECOND(",
        "description": "Returns the millisecond value of a provided time.<br/>Accepts 1 argument: the time to evaluate.",
        "examples": [
          "MILLISECOND(TIMEVALUE(\"12:00:00.123\")) // 123"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "MINUTE",
        "autoCompleteValue": "MINUTE(",
        "description": "Returns the minute value of a provided time.<br/>Accepts 1 argument: the time to evaluate.",
        "examples": [
          "MINUTE(TIMEVALUE(\"12:10:00\")) // 10"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "MONTH",
        "autoCompleteValue": "MONTH(",
        "description": "Returns the month, a number between 1 and 12 (December) in number format of a given date.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "MONTH(DATE(2020, 1, 1)) // 1"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "NOW",
        "autoCompleteValue": "NOW(",
        "description": "Returns the current Datetime in the GMT time zone.<br/>Accepts no arguments.",
        "examples": [
          "NOW() // 2020-01-01 00:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "SECOND",
        "autoCompleteValue": "SECOND(",
        "description": "Returns the second value of a provided time.<br/>Accepts 1 argument: the time to evaluate.",
        "examples": [
          "SECOND(TIMEVALUE(\"12:00:45\")) // 45"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "TIMENOW",
        "autoCompleteValue": "TIMENOW(",
        "description": "Returns the current time.<br/>Accepts no arguments.",
        "examples": [
          "TIMENOW() // 12:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "TIMEVALUE",
        "autoCompleteValue": "TIMEVALUE(",
        "description": "Returns a time value from a datetime or from a string representation of a datetime.<br/>Accepts 1 argument: the datetime or string in datetime format to evaluate.",
        "examples": [
          "TIMEVALUE(DATETIMEVALUE(\"2020-01-01 12:00:00\")) // 12:00:00"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "TODAY",
        "autoCompleteValue": "TODAY(",
        "description": "Returns the current date.<br/>Accepts no arguments.",
        "examples": [
          "TODAY() // 2020-01-01"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "UNIXTIMESTAMP",
        "autoCompleteValue": "UNIXTIMESTAMP(",
        "description": "Returns the number of seconds since 1 Jan 1970 for the given date or datetime,<br/>             or number of seconds in the day for a time.<br/>Values are returned in the GMT time zone.<br/>Accepts 1 argument: the date, datetime, or time to evaluate.",
        "examples": [
          "UNIXTIMESTAMP(DATE(2020, 1, 1)) // 1577836800"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "WEEKDAY",
        "autoCompleteValue": "WEEKDAY(",
        "description": "Returns the day of the week for the given date,<br/>             using 1 for Sunday, 2 for Monday, through 7 for Saturday.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "WEEKDAY(DATE(2020, 1, 1)) // 2"
        ],
        "icon": "utility:date_input"
      },
      {
        "name": "YEAR",
        "autoCompleteValue": "YEAR(",
        "description": "Returns the year value of a provided date.<br/>Accepts 1 argument: the date to evaluate.",
        "examples": [
          "YEAR(DATE(2020, 1, 1)) // 2020"
        ],
        "icon": "utility:date_input"
      }
    ]
  }
];