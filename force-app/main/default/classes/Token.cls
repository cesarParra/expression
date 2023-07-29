public with sharing class Token {
    final TokenType type;
    final String lexeme;
    final Object literal;

    public Token(TokenType type, String lexeme, Object literal) {
        this.type = type;
        this.lexeme = lexeme;
        this.literal = literal;
    }

    public override String toString() {
        return 'Token::Type('+type + ') Lexeme(' + lexeme + ') Literal(' + literal + ')';
    }
}
