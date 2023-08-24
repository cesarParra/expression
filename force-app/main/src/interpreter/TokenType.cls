public enum TokenType {
    // Single-character
    PLUS, MINUS, STAR, SLASH, EXPONENT, LEFT_PAREN, RIGHT_PAREN, COMMA, DOT,

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
    // Date and time
    TODAY_FN,
    HOUR_FN,
    TIMEVALUE_FN,
    TIMENOW_FN,
    ISOWEEK_FN,
    ISOYEAR_FN,
    YEAR_FN,
    MILLISECOND_FN,
    MINUTE_FN,
    SECOND_FN,

    // Math
    ABS_FN,
    CEILING_FN, FLOOR_FN, FROMUNIXTIME_FN, MAX_FN, MIN_FN, ROUND_FN, TRUNC_FN,

    // Lists
    LIST_FN, TOLIST_FN, AVERAGE_FN, SIZE_FN,

    // EOF
    EOF
}
