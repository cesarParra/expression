export const data = [
  {
    "category": "Collection",
    "values": [
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
        "name": "WHERE",
        "autoCompleteValue": "WHERE(",
        "description": "Filters a list using the first argument as the context and the second argument as the expression to evaluate.<br/><br/>Accepts 2 arguments: List of objects and an expression to evaluate.",
        "examples": [
          "WHERE([1, 2, 3], $current > 1)"
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
        "name": "SIZE",
        "autoCompleteValue": "SIZE(",
        "description": "Returns the number of elements in a list or map.<br/><br/>Accepts 1 argument: the list or map to evaluate.",
        "examples": [
          "SIZE(LIST(1, 2, 3)) // 3"
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
        "name": "APPEND",
        "autoCompleteValue": "APPEND(",
        "description": "Appends an item to a list.<br/><br/>Accepts 2 arguments: the list and the item to append.",
        "examples": [
          "APPEND(LIST(1, 2, 3), 4) // [1, 2, 3, 4]"
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
        "name": "KEYS",
        "autoCompleteValue": "KEYS(",
        "description": "Returns a list of keys in a map.",
        "examples": [
          "KEYS(MAP('a' => 1, 'b' => 2, 'c' => 3)) // ['a', 'b', 'c']"
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
        "name": "VALUES",
        "autoCompleteValue": "VALUES(",
        "description": "Returns a list of values in a map.",
        "examples": [
          "VALUES(MAP('a' => 1, 'b' => 2, 'c' => 3)) // [1, 2, 3]"
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
        "name": "FIRST",
        "autoCompleteValue": "FIRST(",
        "description": "Returns the first element in a list.<br/><br/>Accepts 1 argument: the list to evaluate.",
        "examples": [
          "FIRST(LIST(1, 2, 3)) // 1"
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
        "name": "REDUCE",
        "autoCompleteValue": "REDUCE(",
        "description": "Reduces a list to a single value using the first argument as the context, the second argument as the expression to evaluate,<br/><br/>and the third argument as the initial value.<br/><br/>Accepts 3 arguments: List of objects, an expression to evaluate, and the initial value.",
        "examples": [
          "REDUCE([1, 2, 3], $accumulator + $current, 0) // 6"
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
        "name": "AT",
        "autoCompleteValue": "AT(",
        "description": "Returns the element at the specified index. If the list is empty or the<br/><br/>index is out of bounds, this function will return null.<br/><br/>Accepts 2 arguments: the list to evaluate and the index to return.",
        "examples": [
          "AT([1, 2, 3], 1) // 2"
        ],
        "icon": "utility:justify_text"
      },
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
        "name": "SUM",
        "autoCompleteValue": "SUM(",
        "description": "Returns the sum of a list of numbers.<br/><br/>Accepts 1 argument: the list of numbers to evaluate.",
        "examples": [
          "SUM([1, 2, 3]) // 6"
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
      }
    ]
  }
];