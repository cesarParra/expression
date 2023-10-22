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
    category: "Boolean Functions",
    values: [
      {
        name: "NOT",
        autoCompleteValue: "NOT(logical)",
        icon: "utility:check",
        description: "Returns FALSE for TRUE and TRUE for FALSE.",
        syntax: "NOT(logical)",
        examples: [
          "NOT(true)"
        ]
      },
      {
        name: "OR",
        autoCompleteValue: "OR(logical1, logical2)",
        icon: "utility:check",
        description: "Determines if expressions are true or false. Returns TRUE if any expression is true. " +
          "Returns FALSE if all expressions are false. Use this function as an alternative to the operator || (OR).",
        syntax: "OR(logical1, logical2)",
        examples: [
          "OR(true, false)"
        ]
      },
      {
        name: "AND",
        autoCompleteValue: "AND(logical1, logical2)",
        icon: "utility:check",
        description: "Returns a TRUE response if all values are true; returns a FALSE response if one or more " +
          "values are false. Use this function as an alternative to the operator && (AND).",
        syntax: "AND(logical1, logical2)",
        examples: [
          "AND(true, false)"
        ]
      },
      {
        name: "IF",
        autoCompleteValue: "IF(logical_test, value_if_true, value_if_false)",
        icon: "utility:check",
        description: "Determines if expressions are true or false. Returns a given value if true and another value if false.",
        syntax: "IF(logical_test, value_if_true, value_if_false)",
        examples: [
          "IF($User.City = \"Napa\", 100, 200)"
        ]
      }
    ]
  },
  {
    category: "Date Functions",
    values: [
      {
        name: "$TODAY",
        autoCompleteValue: "$TODAY",
        type: "function",
        icon: "utility:date_input",
        description: "Returns the current date as a date data type.",
        syntax: "$TODAY",
        examples: [
          "ADDDAYS($TODAY, 1)"
        ]
      },
      {
        name: "$NOW",
        autoCompleteValue: "$NOW",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a date/time representing the current moment.",
        syntax: "$NOW",
        examples: [
          "ADDHOURS($NOW, 1)"
        ]
      },
      {
        name: "ADDDAYS",
        autoCompleteValue: "ADDDAYS(date, number_of_days)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of days to a date.",
        syntax: "ADDDAYS(date, number_of_days)",
        examples: [
          "ADDDAYS(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "ADDMONTHS",
        autoCompleteValue: "ADDMONTHS(date, number_of_months)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of months to a date.",
        syntax: "ADDMONTHS(date, number_of_months)",
        examples: [
          "ADDMONTHS(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "ADDYEARS",
        autoCompleteValue: "ADDYEARS(date, number_of_years)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of years to a date.",
        syntax: "ADDYEARS(date, number_of_years)",
        examples: [
          "ADDYEARS(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "ADDHOURS",
        autoCompleteValue: "ADDHOURS(time, number_of_hours)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of hours to a date time.",
        syntax: "ADDHOURS(time, number_of_hours)",
        examples: [
          "ADDHOURS(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "ADDMINUTES",
        autoCompleteValue: "ADDMINUTES(time, number_of_minutes)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of minutes to a date time.",
        syntax: "ADDMINUTES(time, number_of_minutes)",
        examples: [
          "ADDMINUTES(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "ADDSECONDS",
        autoCompleteValue: "ADDSECONDS(time, number_of_seconds)",
        type: "function",
        icon: "utility:date_input",
        description: "Adds the specified amount of seconds to a date time.",
        syntax: "ADDSECONDS(time, number_of_seconds)",
        examples: [
          "ADDSECONDS(DATETIME(2019,12,26,0,0,0),1)"
        ]
      },
      {
        name: "DATETIME",
        autoCompleteValue: "DATETIME(expression)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a year, month, day and GMT time value.",
        syntax: "DATETIME(expression)",
        examples: [
          "DATETIME(\"2019-12-26T00:00:00\")",
          "DATETIME(2019,12,26,0,0,0)",
          "DATETIME(\"2019\",12,26,0,0,0)"
        ]
      },
      {
        name: "DATE",
        autoCompleteValue: "DATE(expression)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a date value for a date/time or text expression.",
        syntax: "DATE(expression)",
        examples: [
          "DATE(2019,12,26)",
          "DATE(\"2019\",12,26)"
        ]
      },
      {
        name: "DAY",
        autoCompleteValue: "DAY(date)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a day of the month in the form of a number between 1 and 31.",
        syntax: "DAY(date)",
        examples: [
          "DAY(DATETIME(2019,12,26,0,0,0))"
        ]
      },
      {
        name: "MONTH",
        autoCompleteValue: "MONTH(date)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns the month, a number between 1 (January) and 12 (December) in number format of a given date.",
        syntax: "MONTH(date)",
        examples: [
          "MONTH(DATETIME(2019,12,26,0,0,0))"
        ]
      },
      {
        name: "YEAR",
        autoCompleteValue: "YEAR(date)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns the four-digit year in number format of a given date.",
        syntax: "YEAR(date)",
        examples: [
          "YEAR(DATETIME(2019,12,26,0,0,0))"
        ]
      },
      {
        name: "HOURS",
        autoCompleteValue: "HOURS(time)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns the local time hour value without the date in the form of a number from 1 through 12.",
        syntax: "HOURS(time)",
        examples: [
          "HOURS(DATETIME(2019,12,26,0,0,0))"
        ]
      },
      {
        name: "MINUTES",
        autoCompleteValue: "MINUTES(time)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a minute value in the form of a number from 0 through 60.",
        syntax: "MINUTES(time)",
        examples: [
          "MINUTES(DATETIME(2019,12,26,0,0,0))"
        ]
      },
      {
        name: "SECONDS",
        autoCompleteValue: "SECONDS(time)",
        type: "function",
        icon: "utility:date_input",
        description: "Returns a seconds value in the form of a number from 0 through 60.",
        syntax: "SECONDS(time)",
        examples: [
          "SECONDS(DATETIME(2019,12,26,0,0,0))"
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
