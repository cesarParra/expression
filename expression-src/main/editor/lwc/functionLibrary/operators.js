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
      }
    ]
  },
  {
    category: "Comparison Operators",
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
        name: "Not Equals",
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
    ]
  },
  {
    category: "Boolean Operators",
    values: [
      {
        name: "&&",
        autoCompleteValue: "&&",
        icon: "utility:check",
        description: "Evaluates if two values or expressions are both true. Use this operator as an alternative to the logical function AND.",
        syntax: "boolean && boolean",
        examples: [
          "true && true"
        ]
      },
      {
        name: "||",
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
    category: "Math Operators",
    values: [
      {
        name: "add",
        autoCompleteValue: "+",
        icon: "utility:advanced_function",
        description: "Adds two numbers and returns their sum.",
        syntax: "number + number",
        examples: [
          "3 + 4"
        ]
      },
      {
        name: "subtract",
        autoCompleteValue: "-",
        icon: "utility:advanced_function",
        description: "Subtracts two numbers and returns their difference.",
        syntax: "number - number",
        examples: [
          "3 - 1"
        ]
      },
      {
        name: "multiply",
        autoCompleteValue: "*",
        icon: "utility:advanced_function",
        description: "Multiplies two numbers and returns their product.",
        syntax: "number * number",
        examples: [
          "3 * 2"
        ]
      },
      {
        name: "divide",
        autoCompleteValue: "/",
        icon: "utility:advanced_function",
        description: "Divides two numbers and returns their quotient.",
        syntax: "number / number",
        examples: [
          "4 / 2"
        ]
      },
      {
        name: "pow",
        autoCompleteValue: "POW()",
        icon: "utility:advanced_function",
        description: "Raises a number to a power of a specified number",
        syntax: "POW(number,number)",
        examples: [
          "POW(1,2)"
        ]
      },
      {
        name: "Parenthesis",
        autoCompleteValue: "()",
        icon: "utility:advanced_function",
        description: "Specifies that the expressions within the open parenthesis and close parenthesis are evaluated first. " +
          "All other expressions are evaluated using standard operator precedence.",
        syntax: "(number + number) * number",
        examples: [
          "(5 + 5) * 10"
        ]
      }
    ]
  },
  {
    category: "Math Functions",
    values: [
      {
        name: "MAX",
        autoCompleteValue: "MAX(number, number)",
        icon: "utility:advanced_function",
        description: "Returns the highest number from a list of numbers.",
        syntax: "MAX(number, number)",
        examples: [
          "MAX(5, 10)"
        ]
      },
      {
        name: "MIN",
        autoCompleteValue: "MIN(number, number)",
        icon: "utility:advanced_function",
        description: "Returns the lowest number from a list of numbers.",
        syntax: "MIN(number, number)",
        examples: [
          "MIN(5, 10)"
        ]
      },
      {
        name: "ABS",
        autoCompleteValue: "ABS(number)",
        icon: "utility:advanced_function",
        description: "Calculates the absolute value of a number. The absolute value of a number is the number without its positive or negative sign.",
        syntax: "ABS(number)",
        examples: [
          "ABS(-10)"
        ]
      },
      {
        name: "FLOOR",
        autoCompleteValue: "FLOOR(number)",
        icon: "utility:advanced_function",
        description: "Returns a number rounded down to the nearest integer, towards zero if negative.",
        syntax: "FLOOR(number)",
        examples: [
          "FLOOR(2.5)"
        ]
      },
      {
        name: "CEILING",
        autoCompleteValue: "CEILING(number)",
        icon: "utility:advanced_function",
        description: "Rounds a number up to the nearest integer, away from zero if negative.",
        syntax: "CEILING(number)",
        examples: [
          "CEILING(2.5)"
        ]
      }
    ]
  },
  {
    category: "Text Functions",
    values: [
      {
        name: "LEN",
        autoCompleteValue: "LEN(text)",
        type: "function",
        icon: "utility:text",
        description: "Returns the number of characters in a specified text string.",
        syntax: "LEN(text)",
        examples: [
          "LEN(\"SampleText\")"
        ]
      },
      {
        name: "ISBLANK",
        autoCompleteValue: "ISBLANK(expression)",
        type: "function",
        icon: "utility:text",
        description: "Determines if an expression has a value and returns TRUE if it does not. If it contains a value, this function returns FALSE.",
        syntax: "ISBLANK(expression)",
        examples: [
          "ISBLANK(\"\")"
        ]
      },
      {
        name: "LEFT",
        autoCompleteValue: "LEFT(text, length)",
        type: "function",
        icon: "utility:text",
        description: "Returns the specified number of characters from the beginning of a text string.",
        syntax: "LEFT(text, length)",
        examples: [
          "LEFT(\"text string\", 4)"
        ]
      },
      {
        name: "RIGHT",
        autoCompleteValue: "RIGHT(text, length)",
        type: "function",
        icon: "utility:text",
        description: "Returns the specified number of characters from the end of a text string.",
        syntax: "RIGHT(text, length)",
        examples: [
          "RIGHT(\"text string\", 4)"
        ]
      },
    ]
  }
];
