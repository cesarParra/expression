public with sharing class Parser {
    private final List<Token> tokens;
    private Integer current = 0;

    public Parser(List<Token> tokens) {
        this.tokens = tokens;
    }

    public Expr parse() {
        Expr result = expression();
        if (!isAtEnd()) {
            throw error(peek(), 'Unexpected character after end of expression.');
        }
        return result;
    }

    private Expr equality() {
        Expr expr = comparison();

        while (match(new List<TokenType>{
            TokenType.BANG_EQUAL, TokenType.EQUAL, TokenType.EQUAL_EQUAL, TokenType.LESS_GREATER, TokenType.DOUBLE_PIPE, TokenType.DOUBLE_AMPERSAND
        })) {
            Token operator = previous();
            Expr right = comparison();
            expr = new Expr.Binary(expr, operator, right);
        }

        return expr;
    }

    private Expr comparison() {
        Expr expr = term();

        while (match(
            new List<TokenType>{
                TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL
            }
        )) {
            Token operator = previous();
            Expr right = term();
            expr = new Expr.Binary(expr, operator, right);
        }

        return expr;
    }

    private Expr term() {
        Expr expr = factor();

        while (match(new List<TokenType>{
            TokenType.MINUS, TokenType.PLUS, TokenType.AMPERSAND
        })) {
            Token operator = previous();
            Expr right = factor();
            expr = new Expr.Binary(expr, operator, right);
        }

        return expr;
    }

    private Expr factor() {
        Expr expr = unary();

        while (match(new List<TokenType>{
            TokenType.SLASH, TokenType.STAR, TokenType.EXPONENT
        })) {
            Token operator = previous();
            Expr right = unary();
            expr = new Expr.Binary(expr, operator, right);
        }

        return expr;
    }

    private Expr unary() {
        if (match2(TokenType.BANG, TokenType.MINUS)) {
            Token operator = previous();
            Expr right = unary();
            return new Expr.Unary(operator, right);
        }

        return spread();
    }

    private Expr spread() {
        if (match(TokenType.DOT_DOT_DOT)) {
            Token spreadToken = previous();
            Expr right = getExpr();
            return new Expr.Spread(
                spreadToken,
                right
            );
        }

        return getExpr();
    }

    private Expr getExpr() {
        Expr expr = pipe();

        while (true) {
            if (match(TokenType.DOT)) {
                Token name = consume(TokenType.IDENTIFIER, 'Expect property name after \'.\'.');
                if (peek().type == TokenType.LEFT_PAREN) {
                    List<Expr> parameters = getParameters();
                    expr = new Expr.GetExpr(expr, name, parameters);
                } else {
                    expr = new Expr.GetExpr(expr, name, new List<Expr>());
                }
            } else {
                break;
            }
        }

        return expr;
    }

    private Expr pipe() {
        Expr expr = primary();

        while (match(new List<TokenType>{
            TokenType.ARROW
        })) {
            Token operator = previous();
            Expr right = primary();
            expr = new Expr.Binary(expr, operator, right);
        }

        return expr;
    }

    private Expr primary() {
        if (match(TokenType.FALSE_KEYWORD)) {
            return new Expr.Literal(false);
        }

        if (match(TokenType.TRUE_KEYWORD)) {
            return new Expr.Literal(true);
        }

        if (match(TokenType.NULL_KEYWORD)) {
            return new Expr.Literal(null);
        }

        if (match(TokenType.QUERY_KEYWORD)) {
            return parseQuery();
        }

        if (match(TokenType.STRING_LITERAL_START)) {
            // Grab all characters until we reach the STRING_LITERAL_END
            List<Object> strings = new List<Object>();
            if (!check(TokenType.STRING_LITERAL_END)) {
                while (peek().type != TokenType.STRING_LITERAL_END) {
                    if (match(TokenType.STRING_INTERPOLATION_START)) {
                        Expr expr = expression();
                        strings.add(expr);
                        consume(TokenType.STRING_INTERPOLATION_END, 'Expect "}" after expression.');
                    } else if (match(TokenType.CHARACTER)) {
                        strings.add(previous().literal);
                    } else {
                        throw error(peek(), 'Expect string interpolation or character.');
                    }
                }
            }
            consume(TokenType.STRING_LITERAL_END, 'Expect ".');
            return new Expr.StringLiteral(strings);
        }

        if (match(TokenType.NUMBER_LITERAL)) {
            return new Expr.Literal(previous().literal);
        }

        if (match(TokenType.DOLLAR)) {
            return new Expr.Variable(previous(), Expr.VariableType.LOCAL);
        }

        if (match(TokenType.AT)) {
            return new Expr.Variable(previous(), Expr.VariableType.GLOBAL_CONTEXT);
        }

        if (match(TokenType.IDENTIFIER)) {
            // First check if the identifier is a potential function name
            // by seeing if the next token is a left parenthesis
            if (peek().type == TokenType.LEFT_PAREN) {
                Token fnName = previous();
                List<Expr> parameters = getParameters();
                return new Expr.FunctionCall(fnName, parameters);
            }

            // Otherwise we assume it's a field reference
            return new Expr.MergeField(previous());
        }

        if (match(TokenType.LEFT_PAREN)) {
            Expr expr = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after expression.');
            return new Expr.Grouping(expr);
        }

        if (match(TokenType.LEFT_BRACKET)) {
            List<Expr> elements = new List<Expr>();
            if (!check(TokenType.RIGHT_BRACKET)) {
                do {
                    elements.add(expression());
                } while (match(TokenType.COMMA));
            }
            consume(TokenType.RIGHT_BRACKET, 'Expect \']\' after elements.');
            return new Expr.ListLiteral(elements);
        }

        if (match(TokenType.LEFT_BRACE)) {
            List<Object> elements = new List<Object>();
            if (!check(TokenType.RIGHT_BRACE)) {
                do {
                    Expr key = expression();
                    if (key instanceof Expr.Spread) {
                        elements.add(key);
                        continue;
                    }
                    consume(TokenType.COLON, 'Expect \':\' after key.');
                    Expr value = expression();
                    elements.add(new Expr.KeyValue(key, value));
                } while (match(TokenType.COMMA));
            }
            consume(TokenType.RIGHT_BRACE, 'Expect \'}\' after elements.');
            return new Expr.MapLiteral(elements);
        }

        throw error(peek(), 'Expect expression.');
    }

    private Expr parseQuery() {
        consume(TokenType.LEFT_PAREN, 'Expect \'(\' after \'query\'.');

        if (!match(TokenType.IDENTIFIER)) {
            throw error(peek(), 'Expect object name.');
        }

        Token sObjectType = previous();
        List<String> fields = new List<String>();
        String orderBy;

        if (match(TokenType.LEFT_PAREN)) {
            if (match(TokenType.IDENTIFIER)) {
                String qClause = previous().lexeme.toLowerCase();
                consume(TokenType.COLON, 'Expect \':\' after' + qClause + '');
                if (qClause == 'orderby') {
                    if (match(TokenType.IDENTIFIER)) {
                        orderBy = previous().lexeme;
                    } else {
                        throw error(previous(), 'Expect field name after \'orderBy:\'.');
                    }
                } else {
                    throw error(previous(), 'Expect \'orderBy\' after \'(\'.');
                }
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after query arguments.');
        }

        if (match(TokenType.LEFT_BRACE)) {
            do {
                fields.add(extractFieldFromIdentifierOrDot());
            } while (match(TokenType.COMMA));
            consume(TokenType.RIGHT_BRACE, 'Expect \'}\' after fields.');
        }

        consume(TokenType.RIGHT_PAREN, 'Expect \')\' after query name.');
        return new Expr.Query(sObjectType, fields, orderBy);
    }

    private String extractFieldFromIdentifierOrDot() {
        String field = consume(TokenType.IDENTIFIER, 'Expect field name.').lexeme;
        if (peek().type == TokenType.DOT) {
            // Accounting for parent relationships. When in a Query context
            // we assume that the token types in a "get" expression are
            // always identifiers, as no complex expressions that need to
            // be interpreted are allowed here.
            while (match(TokenType.DOT)) {
                field += '.' + consume(TokenType.IDENTIFIER, 'Expect field name.').lexeme;
            }
        }
        return field;
    }

    private List<Expr> getParameters() {
        consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
        List<Expr> parameters = new List<Expr>();
        if (!check(TokenType.RIGHT_PAREN)) {
            do {
                parameters.add(expression());
            } while (match(TokenType.COMMA));
        }
        consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
        return parameters;
    }

    private Expr expression() {
        return equality();
    }

    private Boolean match(TokenType type) {
        return match(new List<TokenType>{
            type
        });
    }

    private Boolean match2(TokenType type1, TokenType type2) {
        return match(new List<TokenType>{
            type1, type2
        });
    }

    private Boolean match(List<TokenType> types) {
        for (TokenType type : types) {
            if (check(type)) {
                advance();
                return true;
            }
        }

        return false;
    }

    private Boolean check(TokenType type) {
        if (isAtEnd()) {
            return false;
        }

        return peek().type == type;
    }

    private Token advance() {
        if (!isAtEnd()) {
            current++;
        }

        return previous();
    }

    private Boolean isAtEnd() {
        return peek().type == TokenType.EOF;
    }

    private Token peek() {
        return tokens.get(current);
    }

    private Token previous() {
        return tokens.get(current - 1);
    }

    private Token consume(TokenType type, String message) {
        if (check(type)) {
            return advance();
        }

        throw error(peek(), message);
    }

    private static Exceptions.ParsingException error(Token token, String message) {
        throw new Exceptions.ParsingException(
            token,
            message
        );
    }
}
