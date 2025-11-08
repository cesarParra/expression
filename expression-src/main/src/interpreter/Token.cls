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

    public Boolean equals(Object obj) {
        if (!(obj instanceof Token)) {
            return false;
        }
        Token other = (Token)obj;
        return this.type == other.type
            && this.lexeme == other.lexeme
            && this.literal == other.literal;
    }

    public override Integer hashCode() {
        Integer result = System.hashCode(type);
        result = (31 * result) + System.hashCode(lexeme);
        result = (31 * result) + (literal != null ? System.hashCode(literal) : 0);
        return result;
    }
}
