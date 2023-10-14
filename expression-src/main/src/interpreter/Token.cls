public with sharing class Token {
    public final TokenType type;
    public final String lexeme;
    public final Object literal;
    public final Position position;

    public Token(TokenType type, String lexeme, Object literal, Position position) {
        this.type = type;
        this.lexeme = lexeme;
        this.literal = literal;
        this.position = position;
    }

    public override String toString() {
        return
            'Line(' + position.line + ') Column(' + position.column + ') ' +
            'Token::Type('+type + ') Lexeme(' + lexeme + ') Literal(' + literal + ')';
    }

    public class Position {
        public final Integer line;
        public final Integer column;

        public Position(Integer line, Integer column) {
            this.line = line;
            this.column = column;
        }

        public override String toString() {
            return 'Line(' + line + ') Column(' + column + ')';
        }

        public Boolean equals(Object obj) {
            if (obj == null) {
                return false;
            }
            if (obj instanceof Position) {
                Position other = (Position)obj;
                return line == other.line && column == other.column;
            }
            return false;
        }

        public override Integer hashCode() {
            return String.valueOf(line).hashCode() + String.valueOf(column).hashCode();
        }
    }
}
