public enum TokenType {
    // Single-character
    PLUS, MINUS, STAR, SLASH, EXPONENT, LEFT_PAREN, RIGHT_PAREN, COMMA,

    // One or two character
    LESS, LESS_GREATER, LESS_EQUAL,
    BANG, BANG_EQUAL,
    GREATER, GREATER_EQUAL,
    AMPERSAND, DOUBLE_AMPERSAND,
    EQUAL, EQUAL_EQUAL,

    // Two character
    DOUBLE_PIPE,

    // Literals
    IDENTIFIER, STRING_LITERAL, NUMBER_LITERAL,

    // Keywords
    TRUE_KEYWORD, FALSE_KEYWORD, NULL_KEYWORD,

    // Built-in functions
    // Logical
    AND_FN, IF_FN, NOT_FN, OR_FN, BLANKVALUE_FN, ISBLANK_FN,

    // String
    BEGINS_FN, CONTAINS_FN, LOWER_FN, FIND_FN, LEFT_FN,

    // Date
    ADDMONTHS_FN, DATE_FN, DAY_FN,

    // Math
    ABS_FN, CEILING_FN,

    // EOF
    EOF
}
