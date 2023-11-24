export const operators = [
  {
    category: "Constants",
    values: [
      {
        name: "true",
        autoCompleteValue: "true",
        icon: "utility:check",
        description: "Constant for true.",
        syntax: "true",
        examples: [
          "true"
        ]
      },
      {
        name: "false",
        autoCompleteValue: "false",
        icon: "utility:check",
        description: "Constant for false.",
        syntax: "false",
        examples: [
          "false"
        ]
      },
      {
        name: "null",
        autoCompleteValue: "null",
        icon: "utility:steps",
        description: "Constant for null.",
        syntax: "null",
        examples: [
          "null"
        ]
      },
      {
        name: "List literal",
        autoCompleteValue: "[]",
        icon: "utility:list",
        description: "Creates a list of values.",
        examples: [
          "[1, 2, 3]",
          "['a', 'b', 'c']",
        ]
      },
      {
        name: "Map literal",
        autoCompleteValue: "{}",
        icon: "utility:merge_field",
        description: "Creates a map of key-value pairs.",
        examples: [
          '{"a": 1, "b": 2, "c": 3}'
        ]
      },
    ]
  },
  {
    category: "Org Data References",
    values: [
      {
        name: "Custom Label",
        autoCompleteValue: "$Label.",
        icon: "utility:custom_apps",
        description: "References a custom label.",
        syntax: "$Label.namespace.labelName",
        examples: [
          "$Label.c.MyCustomLabel",
          "$Label.namespace.MyCustomLabel"
        ]
      },
      {
        name: "Custom Metadata Type Record's Field",
        autoCompleteValue: "$CustomMetadata.",
        icon: "utility:custom_apps",
        description: "References a custom metadata type record's field value.",
        syntax: "$CustomMetadata.MyCustomMetadataType.MyCustomMetadataRecord.MyField__c",
        examples: [
          "$CustomMetadata.MyCustomMetadataType__mdt.MyCustomMetadataRecordName.MyField__c"
        ]
      },
      {
        name: "Static Resource",
        autoCompleteValue: "$Resource.",
        icon: "utility:custom_apps",
        description: "References a static resource.",
        syntax: "$Resource.resourceName",
        examples: [
          "$Resource.myResource"
        ]
      }
    ]
  },
  {
    category: "Math Operators",
    values: [
      {
        name: "Addition",
        autoCompleteValue: "+",
        icon: "utility:advanced_function",
        description: "Adds two numbers and returns their sum.",
        syntax: "number + number",
        examples: [
          "3 + 4"
        ]
      },
      {
        name: "Subtraction",
        autoCompleteValue: "-",
        icon: "utility:advanced_function",
        description: "Subtracts two numbers and returns their difference.",
        syntax: "number - number",
        examples: [
          "3 - 1"
        ]
      },
      {
        name: "Multiplication",
        autoCompleteValue: "*",
        icon: "utility:advanced_function",
        description: "Multiplies two numbers and returns their product.",
        syntax: "number * number",
        examples: [
          "3 * 2"
        ]
      },
      {
        name: "Division",
        autoCompleteValue: "/",
        icon: "utility:advanced_function",
        description: "Divides two numbers and returns their quotient.",
        syntax: "number / number",
        examples: [
          "4 / 2"
        ]
      },
      {
        name: "Exponentiation",
        autoCompleteValue: "^",
        icon: "utility:advanced_function",
        description: "Raises a number to a power of a specified number",
        syntax: "number ^ number",
        examples: [
          "2 ^ 2"
        ]
      },
    ]
  },
  {
    category: "Misc",
    values: [
      {
        name: "Parenthesis",
        autoCompleteValue: "()",
        icon: "utility:formula",
        description: "Specifies that the expressions within the open parenthesis and close parenthesis are evaluated first. " +
          "All other expressions are evaluated using standard operator precedence.",
        syntax: "(number + number) * number",
        examples: [
          "(5 + 5) * 10"
        ]
      },
      {
        name: "Pipe",
        autoCompleteValue: "->",
        icon: "utility:forward",
        description: "Allows you to chain operations together. The result of the previous operation is passed as the first argument to the next operation. " +
          "This allows you to \"flip\" your code, where a(b) becomes b -> a().",
        syntax: "value -> function",
        examples: [
          "5 -> add(5)"
        ]
      },
    ]
  },
  {
    category: "Logical Operators",
    values: [
      {
        name: "Equals",
        autoCompleteValue: "=",
        icon: "utility:check",
        description: "Evaluates if two values are equivalent. The = and == operator are interchangeable.",
        syntax: "value = value",
        examples: [
          "5 = 5",
          "'text = 'text'"
        ]
      },
      {
        name: "Not Equals (1)",
        autoCompleteValue: "<>",
        icon: "utility:check",
        description: "Evaluates if two values are not equivalent.",
        syntax: "value <> value",
        examples: [
          "5 <> 6",
          "'text' <> 'other text'"
        ]
      },
      {
        name: "Not Equals (2)",
        autoCompleteValue: "!=",
        icon: "utility:check",
        description: "Evaluates if two values are not equivalent.",
        syntax: "value != value",
        examples: [
          "5 != 6",
          "'text' != 'other text'"
        ]
      },
      {
        name: "Less Than",
        autoCompleteValue: "<",
        icon: "utility:check",
        description: "Evaluates if a value is less than the value that follows this symbol.",
        syntax: "value < value",
        examples: [
          "5 < 6"
        ]
      },
      {
        name: "Greater Than",
        autoCompleteValue: ">",
        icon: "utility:check",
        description: "Evaluates if a value is greater than the value that follows this symbol.",
        syntax: "value > value",
        examples: [
          "6 > 5"
        ]
      },
      {
        name: "Less Than Or Equal",
        autoCompleteValue: "<=",
        icon: "utility:check",
        description: "Evaluates if a value is less than or equal to the value that follows this symbol.",
        syntax: "value <= value",
        examples: [
          "5 <= 6"
        ]
      },
      {
        name: "Greater Than Or Equal",
        autoCompleteValue: ">=",
        icon: "utility:check",
        description: "Evaluates if a value is greater than or equal to the value that follows this symbol.",
        syntax: "value >= value",
        examples: [
          "6 >= 5"
        ]
      },
      {
        name: "Logical AND",
        autoCompleteValue: "&&",
        icon: "utility:check",
        description: "Evaluates if two values or expressions are both true. Use this operator as an alternative to the logical function AND.",
        syntax: "boolean && boolean",
        examples: [
          "true && true"
        ]
      },
      {
        name: "Logical OR",
        autoCompleteValue: "||",
        icon: "utility:check",
        description: "Evaluates if at least one of multiple values or expressions is true. Use this operator as an alternative to the logical function OR.",
        syntax: "boolean || boolean",
        examples: [
          "true || false"
        ]
      }
    ]
  },
  {
    category: "String Operators",
    values: [
      {
        name: "Concatenation (1)",
        autoCompleteValue: "&",
        icon: "utility:text",
        description: "Combines two strings into one string.",
        syntax: "string & string",
        examples: [
          "'text' & 'text'"
        ]
      },
      {
        name: "Concatenation (2)",
        autoCompleteValue: "+",
        icon: "utility:text",
        description: "Combines two strings into one string.",
        syntax: "string + string",
        examples: [
          "'text' + 'text'"
        ]
      },
    ]
  },
  {
    category: "List and Map Operators",
    values: [
      {
        name: "Spread",
        autoCompleteValue: "...",
        icon: "utility:threedots",
        description: "When used within a list, it expands the list into its elements. When used within a map, it expands the map into its key-value pairs.",
        syntax: "[...list]",
        examples: [
          "[...[1, 2, 3]]",
          "[...{a: 1, b: 2}]"
        ]
      },
    ]
  }
];
