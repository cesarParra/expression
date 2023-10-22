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
  }
];

// TODO:
// TODO
// TODO: There are a lot of things that still need to be included here, like [], spread operator, pipe operator, {}, etc.
