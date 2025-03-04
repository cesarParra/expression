public with sharing class Scanner {
    private final String source;
    private final List<Token> tokens = new List<Token>();
    private Integer start = 0;
    private Integer current = 0;
    private Integer column = 1;
    private Integer line = 1;

    private static final Map<String, TokenType> keywords;

    static {
        keywords = new Map<String, TokenType>();
        keywords.put('true', TokenType.TRUE_KEYWORD);
        keywords.put('false', TokenType.FALSE_KEYWORD);
        keywords.put('null', TokenType.NULL_KEYWORD);
        keywords.put('query', TokenType.QUERY_KEYWORD);
        keywords.put('asc', TokenType.ASC_KEYWORD);
        keywords.put('desc', TokenType.DESC_KEYWORD);
        keywords.put('fun', TokenType.FUNCTION_KEYWORD);
        keywords.put('nocache', TokenType.NOCACHE_KEYWORD);
        keywords.put('addif', TokenType.ADD_IF_KEYWORD);
    }

    public Scanner(String source) {
        this.source = source;
    }

    public List<Token> scanTokens() {
        while (!isAtEnd()) {
            start = current;
            scanToken();
        }

        tokens.add(new Token(TokenType.EOF, '', null, new SourcePosition(line, column, column)));
        return tokens;
    }

    private void scanToken() {
        String character = advance();

        switch on character {
            // Single characters
            when '+' {
                addToken(TokenType.PLUS);
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
            when '[' {
                addToken(TokenType.LEFT_BRACKET);
            }
            when ']' {
                addToken(TokenType.RIGHT_BRACKET);
            }
            when '{' {
                addToken(TokenType.LEFT_BRACE);
            }
            when '}' {
                addToken(TokenType.RIGHT_BRACE);
            }
            when ':' {
                addToken(TokenType.COLON);
            }
            when ';' {
                addToken(TokenType.SEMICOLON);
            }

            // One or more character tokens
            when '=' {
                String next = peek();
                if (next == '=') {
                    advance();
                    addToken(TokenType.EQUAL_EQUAL);
                } else if (next == '>') {
                    advance();
                    addToken(TokenType.FAT_ARROW);
                } else {
                    addToken(TokenType.EQUAL);
                }
            }

            when '.' {
                addToken(match2('..') ? TokenType.SPREAD : TokenType.DOT);
            }

            when '-' {
                addToken(match('>') ? TokenType.ARROW : TokenType.MINUS);
            }

            when '$' {
                variableAccess();
            }

            when '@' {
                contextAccess();
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
                    Integer column = this.column - 1;
                    throw new Exceptions.ParsingException(
                        new SourcePosition(line, column, column + 1),
                        'Unexpected character' + next + ' Expected another | for an OR operator');
                }
            }

            when '#' {
                // Ignore comments
                while (peek() != '\n' && !isAtEnd()) {
                    advance();
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
                    Integer column = this.column - 1;
                    throw new Exceptions.ParsingException(
                        new SourcePosition(line, column, column + 1),
                        'Unexpected character: ' + character);
                }
            }
        }
    }

    private String advance() {
        current++;
        column++;
        String c = source.substring(current - 1, current);
        if (c == '\n') {
            line++;
            column = 1;
        }
        return c;
    }

    private void addToken(TokenType type) {
        addToken(type, null, null);
    }

    private void addToken(TokenType type, Object literal) {
        addToken(type, literal, null);
    }

    private void addToken(TokenType type, Object literal, SourcePosition position) {
        String text = source.substring(start, current);
        Integer column = this.column - text.length();
        SourcePosition pos = position != null ?
            position :
            new SourcePosition(line, column, column + text.length());
        tokens.add(new Token(type, text, literal, pos));
    }

    private Boolean match(String expected) {
        if (isAtEnd()) return false;
        if (!source.substring(current, current + 1).equals(expected)) return false;

        current++;
        column++;
        return true;
    }

    private Boolean match2(String str) {
        if (isAtEnd()) return false;
        // Check that there are enough characters remaining before trying to match
        if (current + 1 >= source.length()) return false;
        if (!source.substring(current, current + 2).equals(str)) return false;

        current += 2;
        column += 2;
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
        addToken(TokenType.STRING_LITERAL_START);

        while (peek() != '"' && !isAtEnd()) {
            if (peek() == '$' && peekNext() == '{') {
                // Consume the $ and {
                start = current;
                advance();
                advance();
                addToken(TokenType.STRING_INTERPOLATION_START);

                // We've found string interpolation
                while (peek() != '}' && !isAtEnd()) {
                    start = current;
                    scanToken();
                }

                if (isAtEnd()) {
                    throw new Exceptions.ParsingException(
                        new SourcePosition(line, column, column + 1),
                        'Unterminated string');
                }

                // The closing }
                start = current;
                advance();
                addToken(TokenType.STRING_INTERPOLATION_END);
            } else {
                start = current;
                addToken(TokenType.CHARACTER, advance());
            }
        }

        if (isAtEnd()) {
            throw new Exceptions.ParsingException(
                new SourcePosition(line, column, column + 1),
                'Unterminated string');
        }

        // The closing "
        start = current;
        advance();
        addToken(TokenType.STRING_LITERAL_END);
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

    private void variableAccess() {
        while (isValidSalesforceIdentifier(peek())) {
            advance();
        }

        TokenType type = TokenType.CUSTOM_VARIABLE;
        addToken(type);
    }

    private void contextAccess() {
        while (isValidSalesforceIdentifier(peek())) {
            advance();
        }

        TokenType type = TokenType.GLOBAL_CONTEXT_VARIABLE;
        addToken(type);
    }

    private void identifierLiteral() {
        while (isValidSalesforceIdentifier(peek())) {
            advance();
        }

        // See if the identifier is a reserved word
        // Formulas are case insensitive, so we need to lowercase the identifier
        String text = source.substring(start, current).toLowerCase();
        TokenType type = keywords.get(text) ?? TokenType.IDENTIFIER;
        addToken(type);
    }

    private static Boolean isValidSalesforceIdentifier(String identifier) {
        // Any alphanumeric character, and underscores
        Pattern p = Pattern.compile('^[a-zA-Z0-9_]+$');
        Matcher m = p.matcher(identifier);
        return m.matches();
    }

    private Boolean isAtEnd() {
        return current >= source.length();
    }
}
