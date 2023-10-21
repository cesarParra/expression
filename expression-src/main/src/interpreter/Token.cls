public with sharing class Token {
    public final TokenType type;
    public final String lexeme;
    public final Object literal;
    public final SourcePosition position;

    public Token(TokenType type, String lexeme, Object literal, SourcePosition position) {
        this.type = type;
        this.lexeme = lexeme;
        this.literal = literal;
        this.position = position;
    }
}
