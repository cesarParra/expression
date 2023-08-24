public with sharing class Scanner {
    private final String source;
    private final List<Token> tokens = new List<Token>();
    private Integer start = 0;
    private Integer current = 0;

    private static final Map<String, TokenType> keywords;

    static {
        keywords = new Map<String, TokenType>();
        keywords.put('true', TokenType.TRUE_KEYWORD);
        keywords.put('false', TokenType.FALSE_KEYWORD);
        keywords.put('null', TokenType.NULL_KEYWORD);

        // TODO: Functions start here
        keywords.put('abs', TokenType.ABS_FN);
        keywords.put('ceiling', TokenType.CEILING_FN);
        keywords.put('floor', TokenType.FLOOR_FN);
        keywords.put('fromunixtime', TokenType.FROMUNIXTIME_FN);
        keywords.put('max', TokenType.MAX_FN);
        keywords.put('min', TokenType.MIN_FN);
        keywords.put('round', TokenType.ROUND_FN);
        keywords.put('trunc', TokenType.TRUNC_FN);
        keywords.put('isoweek', TokenType.ISOWEEK_FN);
        keywords.put('isoyear', TokenType.ISOYEAR_FN);
        keywords.put('year', TokenType.YEAR_FN);
        keywords.put('list', TokenType.LIST_FN);
        keywords.put('tolist', TokenType.TOLIST_FN);
        keywords.put('average', TokenType.AVERAGE_FN);
        keywords.put('size', TokenType.SIZE_FN);
    }

    public Scanner(String source) {
        this.source = source;
    }

    public List<Token> scanTokens() {
        while (!isAtEnd()) {
            start = current;
            scanToken();
        }

        tokens.add(new Token(TokenType.EOF, '', null));
        return tokens;
    }

    private void scanToken() {
        String character = advance();

        switch on character {
            // Single characters
            when '+' {
                addToken(TokenType.PLUS);
            }
            when '-' {
                addToken(TokenType.MINUS);
            }
            when '*' {
                addToken(TokenType.STAR);
            }
            when '/' {
                addToken(TokenType.SLASH);
            }
            when '^' {
                addToken(TokenType.EXPONENT);
            }
            when '(' {
                addToken(TokenType.LEFT_PAREN);
            }
            when ')' {
                addToken(TokenType.RIGHT_PAREN);
            }
            when ',' {
                addToken(TokenType.COMMA);
            }
            when '.' {
                addToken(TokenType.DOT);
            }

            // One or more character tokens
            when '=' {
                addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
            }
            when '<' {
                String next = peek();
                if (next == '=') {
                    advance();
                    addToken(TokenType.LESS_EQUAL);
                } else if (next == '>') {
                    advance();
                    addToken(TokenType.LESS_GREATER);
                } else {
                    addToken(TokenType.LESS);
                }
            }
            when '!' {
                addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
            }
            when '>' {
                addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
            }
            when '&' {
                addToken(match('&') ? TokenType.DOUBLE_AMPERSAND : TokenType.AMPERSAND);
            }
            when '|' {
                String next = peek();
                if (next == '|') {
                    advance();
                    addToken(TokenType.DOUBLE_PIPE);
                } else {
                    throw new ScannerException('Unexpected character' + next + ' Expected another | for an OR operator');
                }
            }

            when ' ', '\r', '\t', '\n' {
                // Ignore whitespace
            }

            when '"' {
                stringLiteral();
            }

            when else {
                if (character.isNumeric()) {
                    numberLiteral();
                } else if (character.isAlpha()) {
                    identifierLiteral();
                } else {
                    throw new ScannerException('Unexpected character: ' + character);
                }
            }
        }
    }

    private String advance() {
        current++;
        return source.substring(current - 1, current);
    }

    private void addToken(TokenType type) {
        addToken(type, null);
    }

    private void addToken(TokenType type, Object literal) {
        String text = source.substring(start, current);
        tokens.add(new Token(type, text, literal));
    }

    private Boolean match(String expected) {
        if (isAtEnd()) return false;
        if (!source.substring(current, current + 1).equals(expected)) return false;

        current++;
        return true;
    }

    private String peek() {
        if (isAtEnd()) return '';
        return source.substring(current, current + 1);
    }

    private String peekNext() {
        if (current + 1 >= source.length()) return '';
        return source.substring(current + 1, current + 2);
    }

    private void stringLiteral() {
        while (peek() != '"' && !isAtEnd()) {
            advance();
        }

        if (isAtEnd()) {
            throw new ScannerException('Unterminated string');
        }

        // The closing "
        advance();

        // Trim the surrounding quotes
        String value = source.substring(start + 1, current - 1);
        addToken(TokenType.STRING_LITERAL, value);
    }

    private void numberLiteral() {
        while (peek().isNumeric()) {
            advance();
        }

        // Look for a fractional part
        if (peek() == '.' && peekNext().isNumeric()) {
            // Consume the "."
            advance();

            while (peek().isNumeric()) {
                advance();
            }
        }

        addToken(TokenType.NUMBER_LITERAL, Decimal.valueOf(source.substring(start, current)));
    }

    private void identifierLiteral() {
        while (peek().isAlphanumeric()) {
            advance();
        }

        // See if the identifier is a reserved word
        // Formulas are case insensitive, so we need to lowercase the identifier
        String text = source.substring(start, current).toLowerCase();
        TokenType type = keywords.get(text);
        if (type == null) {
            type = TokenType.IDENTIFIER;
        }
        addToken(type);
    }

    private Boolean isAtEnd() {
        return current >= source.length();
    }

    public class ScannerException extends Exception {
    }
}
