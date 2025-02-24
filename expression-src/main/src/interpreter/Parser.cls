public with sharing class Parser {
    private final List<Token> tokens;
    private Integer current = 0;

    public Parser(List<Token> tokens) {
        this.tokens = tokens;
    }

    public List<Expr> parse() {
        List<Expr> exprs = new List<Expr>();
        while (!isAtEnd()) {
            exprs.add(expression());
        }

        return exprs;
    }

    private static Boolean hasParameter(List<Token> parameters, Token parameter) {
        for (Token p : parameters) {
            if (p.lexeme.toLowerCase() == parameter.lexeme.toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    private Expr functionDeclarationCheck() {
        if (match(TokenType.FUNCTION_KEYWORD)) {
            Token name = consume(TokenType.IDENTIFIER, 'Expect function name.');
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            List<Token> parameters = new List<Token>();
            if (!check(TokenType.RIGHT_PAREN)) {
                do {
                    Token parameter = consume(TokenType.IDENTIFIER, 'Expect parameter name.');
                    if (hasParameter(parameters, parameter)) {
                        throw error(parameter, 'Parameter name "' + parameter.lexeme + '" is already defined.');
                    }
                    parameters.add(parameter);
                } while (match(TokenType.COMMA));
            }
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            consume(TokenType.FAT_ARROW, 'Expect \'=>\' before function body.');
            Expr body = expression();
            consume(TokenType.SEMICOLON, 'Expect \';\' after function body.');
            return new Expr.FunctionDeclaration(name, parameters, body);
        }
        return orCheck();
    }

    private Expr orCheck() {
        Expr expr = andCheck();

        while (match(TokenType.DOUBLE_PIPE)) {
            Token operator = previous();
            Expr right = andCheck();
            expr = new Expr.Logical(expr, operator, right);
        }

        return expr;
    }

    private Expr andCheck() {
        Expr expr = equality();

        while (match(TokenType.DOUBLE_AMPERSAND)) {
            Token operator = previous();
            Expr right = equality();
            expr = new Expr.Logical(expr, operator, right);
        }

        return expr;
    }

    private Expr equality() {
        Expr expr = comparison();

        while (match(new List<TokenType>{
            TokenType.BANG_EQUAL, TokenType.EQUAL, TokenType.EQUAL_EQUAL,
            TokenType.LESS_GREATER
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

        if (match(TokenType.CUSTOM_VARIABLE)) {
            return new Expr.Variable(previous(), Expr.VariableType.LOCAL);
        }

        if (match(TokenType.GLOBAL_CONTEXT_VARIABLE)) {
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
            return new Expr.MergeFieldOrScopeVariable(previous());
        }

        if (match(TokenType.LEFT_PAREN)) {
            Integer checkpoint = current;

            // Try to parse parameters for a potential anonymous function
            List<Token> parameters = new List<Token>();
            Boolean isPotentialFunction = true;

            // Handle empty parameter list
            if (!check(TokenType.RIGHT_PAREN)) {
                do {
                    // If we encounter something that's not an identifier, this is a grouping
                    if (!check(TokenType.IDENTIFIER)) {
                        isPotentialFunction = false;
                        break;
                    }
                    Token parameter = consume(TokenType.IDENTIFIER, 'Expect parameter name.');
                    if (hasParameter(parameters, parameter)) {
                        throw error(parameter, 'Parameter name "' + parameter.lexeme + '" is already defined.');
                    }
                    parameters.add(parameter);

                    if (!check(TokenType.COMMA) || !check(TokenType.RIGHT_PAREN)) {
                        isPotentialFunction = false;
                        break;
                    }
                } while (match(TokenType.COMMA));
            }

            // Check if next token after ) is =>
            if (isPotentialFunction) {
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
                if (match(TokenType.FAT_ARROW)) {
                    Expr body = expression();
                    // Pass null as the name since it's anonymous
                    return new Expr.FunctionDeclaration(null, parameters, body);
                }
            }

            // If we get here, this is a grouping expression
            // Reset position and parse as grouping
            current = checkpoint;
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
        Expr fieldsExpression;
        List<Expr> orderBys = new List<Expr>();
        Expr limitExpr;
        Expr whereExpr;
        Expr offsetExpr;

        // Optional named parameters section that define the "extra" parts of the query (order by, where, limit, etc.).
        if (match(TokenType.LEFT_PAREN)) {
            if (peek().type == TokenType.IDENTIFIER) {
                do {
                    String qClause = consume(TokenType.IDENTIFIER, 'Expect query clause name.').lexeme;
                    consume(TokenType.COLON, 'Expect \':\' after' + qClause + '');
                    if (qClause == 'orderby') {
                        orderBys = getOrderBys();
                    } else if (qClause == 'limit') {
                        limitExpr = expression();
                    } else if (qClause == 'where') {
                        whereExpr = expression();
                    } else if (qClause == 'offset') {
                        offsetExpr = expression();
                    } else {
                        throw error(previous(), 'Expect one of \'orderby\', \'limit\', \'where\', or \'offset\'.');
                    }
                } while (match(TokenType.COMMA));
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after query arguments.');
        }

        // Optional expression that defines the fields to be returned in the query.
        if (peek().type != TokenType.RIGHT_PAREN) {
            fieldsExpression = expression();
        }

        consume(TokenType.RIGHT_PAREN, 'Expect \')\' to close the query.');
        return new Expr.Query(sObjectType, fieldsExpression, orderBys, limitExpr, whereExpr, offsetExpr);
    }

    private List<Expr> getOrderBys() {
        List<Expr> orderBys = new List<Expr>();
        // Check if the next one is a LEFT_BRACKET
        if (match(TokenType.LEFT_BRACKET)) {
            do {
                Expr orderBy = extractOrderby();
                orderBys.add(orderBy);
            } while (match(TokenType.COMMA));
            consume(TokenType.RIGHT_BRACKET, 'Expect \']\' to close list of order by references.');
        } else {
            // Assume we have a single field reference
            Expr orderBy = extractOrderby();
            orderBys.add(orderBy);
        }

        return orderBys;
    }

    private Expr extractOrderby() {
        Expr orderByExpr = expression();
        // The expression might be followed by (optionally) the ASC or DESC keyword
        if (match(new List<TokenType>{
            TokenType.ASC_KEYWORD, TokenType.DESC_KEYWORD
        })) {
            QOrder.SortOrder qSortOrder = previous().lexeme == 'ASC' ? QOrder.SortOrder.ASCENDING : QOrder.SortOrder.DESCENDING;
            return new Expr.Binary(orderByExpr, null, new Expr.Literal(qSortOrder));
        } else {
            // Default to ASC
            return new Expr.Binary(orderByExpr, null, new Expr.Literal(QOrder.SortOrder.ASCENDING));
        }
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
        return functionDeclarationCheck();
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
