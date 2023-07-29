public enum TokenType {
    // Single-character
    PLUS, MINUS, STAR, SLASH, EXPONENT, LEFT_PAREN, RIGHT_PAREN, COMMA,

    // One or two character
    LESS, LESS_GREATER, LESS_EQUAL,
    BANG, BANG_EQUAL,
    GREATER, GREATER_EQUAL,
    AMPERSAND, DOUBLE_AMPERSAND,

    // Two character
    EQUAL_EQUAL,
    DOUBLE_PIPE,

    // Literals
    IDENTIFIER, STRING_LITERAL, NUMBER_LITERAL,

    // EOF
    EOF
}
