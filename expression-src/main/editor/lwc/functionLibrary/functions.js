export const data = [
  {
    "category": "Collection",
    "values": [
      {
        "name": "ANY",
        "autoCompleteValue": "ANY(",
        "description": "Returns true if any element in the list matches the given expression.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "ANY([1, 2, 3], $current = 2) // true"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "APPEND",
        "autoCompleteValue": "APPEND(",
        "description": "Appends an item to a list.<br/><br/>Accepts 2 arguments: the list and the item to append.",
        "examples": [
          "APPEND(LIST(1, 2, 3), 4) // [1, 2, 3, 4]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "AT",
        "autoCompleteValue": "AT(",
        "description": "Returns the element at the specified index. If the list is empty or the<br/><br/>index is out of bounds, this function will return null.<br/><br/>Accepts 2 arguments: the list to evaluate and the index to return.",
        "examples": [
          "AT([1, 2, 3], 1) // 2"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "AVERAGE",
        "autoCompleteValue": "AVERAGE(",
        "description": "Returns the average given a list of numbers.<br/><br/>Accepts 1 argument: the list of numbers to evaluate.",
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
        "description": "Returns true if every element in the list matches the given expression.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "EVERY([1, 2, 3], $current > 0) // true"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "EXPAND",
        "autoCompleteValue": "EXPAND(",
        "description": "Expands each element of a list into zero or more elements, resulting from the<br/><br/>evaluation of the given expression.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate. The expression<br/><br/>must return a list.",
        "examples": [
          "EXPAND([1, 2, 3], LIST($current, $current + 1)) // [1, 2, 2, 3, 3, 4]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FIRST",
        "autoCompleteValue": "FIRST(",
        "description": "Returns the first element in a list.<br/><br/>Accepts 1 argument: the list to evaluate.",
        "examples": [
          "FIRST(LIST(1, 2, 3)) // 1"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FIRSTWHERE",
        "autoCompleteValue": "FIRSTWHERE(",
        "description": "Returns the first element of a list that matches the given expression or null<br/><br/>if the list is empty or no element matches the expression.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "FIRSTWHERE([1, 2, 3], $current > 2) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "FOLLOWEDBY",
        "autoCompleteValue": "FOLLOWEDBY(",
        "description": "Appends a list to another list.<br/><br/>Accepts 2 arguments: the list to append to and the list to append.",
        "examples": [
          "FOLLOWEDBY([1, 2, 3], [4, 5, 6])"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "GET",
        "autoCompleteValue": "GET(",
        "description": "Returns the value of a key in a map or the field in an SObject.<br/><br/>Accepts 2 arguments: the map or SObject to evaluate and the key to get.",
        "examples": [
          "GET(MAP('a' => 1, 'b' => 2, 'c' => 3), 'a') // 1"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "ISEMPTY",
        "autoCompleteValue": "ISEMPTY(",
        "description": "Returns true if the list or map is empty.<br/><br/>Accepts 1 argument: the list or map to evaluate.",
        "examples": [
          "ISEMPTY(LIST(1, 2, 3)) // false"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "JOIN",
        "autoCompleteValue": "JOIN(",
        "description": "Joins a list of values into a string using the specified delimiter.<br/><br/>Accepts 2 arguments: the list to join and the delimiter.",
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
        "description": "Returns the last element in a list.<br/><br/>Accepts 1 argument: the list to evaluate.",
        "examples": [
          "LAST(LIST(1, 2, 3)) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "LASTWHERE",
        "autoCompleteValue": "LASTWHERE(",
        "description": "Returns the last element of a list that matches the given expression or null<br/><br/>if the list is empty or no element matches the expression.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
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
        "description": "Maps to a list using the first argument as the context and the second argument as the expression to evaluate.<br/><br/>Accepts 2 arguments: List of objects and an expression to evaluate.",
        "examples": [
          "MAP([\"a\", \"b\", \"c\"], UPPER($current))"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "PUT",
        "autoCompleteValue": "PUT(",
        "description": "Adds a key/value pair to a map.<br/><br/>Accepts 3 arguments: the map to add to, the key to add, and the value to add.",
        "examples": [
          "PUT({ \"a\": 1, \"b\": 2, \"c\": 3 }, \"d\", 4) // { \"a\": 1, \"b\": 2, \"c\": 3, \"d\": 4 }"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "RANGE",
        "autoCompleteValue": "RANGE(",
        "description": "Returns a list of numbers from the start to the end, inclusive.<br/><br/>Accepts 2 arguments: the start and end numbers.",
        "examples": [
          "RANGE(1, 3) // [1, 2, 3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "REDUCE",
        "autoCompleteValue": "REDUCE(",
        "description": "Reduces a list to a single value using the first argument as the context, the second argument as the expression to evaluate,<br/><br/>and the third argument as the initial value.<br/><br/>Accepts 3 arguments: List of objects, an expression to evaluate, and the initial value.",
        "examples": [
          "REDUCE([1, 2, 3], $accumulator + $current, 0) // 6"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SIZE",
        "autoCompleteValue": "SIZE(",
        "description": "Returns the number of elements in a list or map.<br/><br/>Accepts 1 argument: the list or map to evaluate.",
        "examples": [
          "SIZE(LIST(1, 2, 3)) // 3"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SKIP",
        "autoCompleteValue": "SKIP(",
        "description": "Skips the first N elements of a list.<br/><br/>Accepts 2 arguments: the list to skip and the number of elements to skip.",
        "examples": [
          "SKIP([1, 2, 3], 2) // [3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SKIPWHILE",
        "autoCompleteValue": "SKIPWHILE(",
        "description": "Skips elements of a list while the given expression evaluates to true.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
        "examples": [
          "SKIPWHILE([1, 2, 3], $current < 3) // [3]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SORT",
        "autoCompleteValue": "SORT(",
        "description": "Sorts a list.<br/><br/>Accepts at least one argument: the list to sort.<br/><br/>When sorting a list of Maps or a list of SObjects,<br/><br/>two additional arguments can be provided: the field to sort by and the sort direction.<br/><br/>The field to sort can either be a field name as a merge field (field name without quotes), or an expression that evaluates to a string<br/><br/>representing the field name. Merge fields are only supported when sorting SObjects and are useful to get the framework to automatically<br/><br/>query the field for you.<br/><br/>Note: The merge field must be a field on the SObject being sorted itself, not a relationship field.<br/><br/>The sort direction can either be the literal string (requires quotes) `ASC` or `DESC`.",
        "examples": [
          "SORT([{ \"a\": 3 }, { \"a\": 2 }, { \"a\": 1 }], \"a\", \"DESC\") // [{ \"a\": 3 }, { \"a\": 2 }, { \"a\": 1 }]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "SUM",
        "autoCompleteValue": "SUM(",
        "description": "Returns the sum of a list of numbers.<br/><br/>Accepts 1 argument: the list of numbers to evaluate.",
        "examples": [
          "SUM([1, 2, 3]) // 6"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "TAKE",
        "autoCompleteValue": "TAKE(",
        "description": "Returns the first N elements of a list.<br/><br/>Accepts 2 arguments: the list to take from and the number of elements to take.",
        "examples": [
          "TAKE([1, 2, 3], 2) // [1, 2]"
        ],
        "icon": "utility:justify_text"
      },
      {
        "name": "TAKEWHILE",
        "autoCompleteValue": "TAKEWHILE(",
        "description": "Returns elements of a list while the given expression evaluates to true.<br/><br/>Provides 1 special variable in the inner expression: `$current` (the current item being iterated over).<br/><br/>Accepts 2 arguments: the list to evaluate and the expression to evaluate.",
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
        "description": "Filters a list using the first argument as the context and the second argument as the expression to evaluate.<br/><br/>Accepts 2 arguments: List of objects and an expression to evaluate.",
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
        "description": "Allows you to query data from the database. This is useful<br/><br/>when the data you want to use is not provided as part of the context.<br/><br/>TTakes 2 arguments: a string with the `SObjectName` you wish to extract data from,<br/><br/>and a list of strings with the fields you wish to extract. This will query all the records of the given<br/><br/>type and return a list of `SObjects` with the data.<br/><br/>Note that when using this function, the automatic context resolution is not performed, so you need to<br/><br/>explicitly specify all fields you wish to reference in the formula.",
        "examples": [
          "FETCH(\"Account\", [\"Id\", \"Name\"])"
        ],
        "icon": "utility:data_mapping"
      },
      {
        "name": "LET",
        "autoCompleteValue": "LET(",
        "description": "Allows you to define custom variables that can be used in the expression.<br/><br/>Accepts 2 arguments: a map of variables to define and the expression to evaluate.<br/><br/>The map keys should be the variable names prefixed with `$`.",
        "examples": [
          "LET({ \"$a\": 1, \"$b\": 2 }, $a + $b) // 3"
        ],
        "icon": "utility:data_mapping"
      },
      {
        "name": "TRANSFORM",
        "autoCompleteValue": "TRANSFORM(",
        "description": "Transforms any input using the provided expression.<br/><br/>Provides a special variable `$source` in the inner expression that contains the original input.<br/><br/>Accepts 2 arguments: the input to transform and the expression to evaluate.",
        "examples": [
          "TRANSFORM(\"Hello World\", UPPER($source)) // \"HELLO WORLD\""
        ],
        "icon": "utility:data_mapping"
      }
    ]
  }
];