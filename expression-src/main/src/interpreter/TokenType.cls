public enum TokenType {
    // --------------- Single-character ---------------
    PLUS, MINUS, STAR, SLASH, EXPONENT, LEFT_PAREN, RIGHT_PAREN, COMMA,
    LEFT_BRACKET, RIGHT_BRACKET, LEFT_BRACE, RIGHT_BRACE, COLON, HASH,

    // --------------- One or two character ---------------
    LESS, LESS_GREATER, LESS_EQUAL,
    BANG, BANG_EQUAL,
    GREATER, GREATER_EQUAL,
    AMPERSAND, DOUBLE_AMPERSAND,
    EQUAL, EQUAL_EQUAL,

    // ->. Use for piping.
    ARROW,

    // ---------------- One or more character ---------------
    DOT, DOT_DOT_DOT,

    // ----------------- Two character -----------------
    DOUBLE_PIPE,

    // ----------------- Literals -----------------
    IDENTIFIER, STRING_LITERAL_START,
    // ${} is used for string interpolation.
    STRING_INTERPOLATION_START, STRING_INTERPOLATION_END,
    STRING_LITERAL_END, CHARACTER, NUMBER_LITERAL,
    // $. Used for custom variables and context aware variables
    DOLLAR,
    // @. Used for global context variables
    AT,

    // ----------------- Keywords -----------------
    TRUE_KEYWORD, FALSE_KEYWORD, NULL_KEYWORD, QUERY_KEYWORD,
    ASC_KEYWORD, DESC_KEYWORD,

    // ----------------- EOF ----------------------
    EOF
}
