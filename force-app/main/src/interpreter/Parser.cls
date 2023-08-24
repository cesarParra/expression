public with sharing class Parser {
    private final List<Token> tokens;
    private Integer current = 0;

    public Parser(List<Token> tokens) {
        this.tokens = tokens;
    }

    public Expr parse() {
        return expression();
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

        return getExpr();
    }

    private Expr getExpr() {
        Expr expr = primary();

        while (true) {
            if (match(TokenType.DOT)) {
                Token name = consume(TokenType.IDENTIFIER, 'Expect property name after \'.\'.');
                expr = new Expr.GetExpr(expr, name);
            } else {
                break;
            }
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

        if (match2(TokenType.NUMBER_LITERAL, TokenType.STRING_LITERAL)) {
            return new Expr.Literal(previous().literal);
        }

        if (match(TokenType.IDENTIFIER)) {
            // First check if the identifier is a potential function name
            // by seeing if the next token is a left parenthesis
            if (peek().type == TokenType.LEFT_PAREN) {
                Token fnName = previous();
                consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
                List<Expr> parameters = new List<Expr>();
                if (!check(TokenType.RIGHT_PAREN)) {
                    do {
                        parameters.add(expression());
                    } while (match(TokenType.COMMA));
                }
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
                return new Expr.CallableFunction(fnName.lexeme.toUpperCase(), parameters);
            }

            // Otherwise we assume it's a field reference
            return new Expr.MergeField(previous());
        }

        if (match(new List<TokenType>{
            TokenType.MAX_FN, TokenType.MIN_FN,
            TokenType.LIST_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            List<Expr> parameters = new List<Expr>();
            if (!check(TokenType.RIGHT_PAREN)) {
                do {
                    parameters.add(expression());
                } while (match(TokenType.COMMA));
            }
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, parameters);
        }

        if (match(TokenType.DATE_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr year = expression();
            consume(TokenType.COMMA, 'Expect \',\' after year.');
            Expr month = expression();
            consume(TokenType.COMMA, 'Expect \',\' after month.');
            Expr day = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                year, month, day
            });
        }

        if (match(new List<TokenType>{
            TokenType.ABS_FN, TokenType.CEILING_FN, TokenType.FLOOR_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr numberValue = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                numberValue
            });
        }

        if (match(new List<TokenType>{
            TokenType.DAY_FN, TokenType.DAYOFYEAR_FN, TokenType.DATEVALUE_FN,
            TokenType.DATETIMEVALUE_FN, TokenType.HOUR_FN, TokenType.ISOWEEK_FN,
            TokenType.ISOYEAR_FN, TokenType.YEAR_FN, TokenType.MILLISECOND_FN,
            TokenType.MINUTE_FN, TokenType.SECOND_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr dateValue = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                dateValue
            });
        }

        if (match(TokenType.TIMEVALUE_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr dateTimeValueOrText = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                dateTimeValueOrText
            });
        }

        if (match(TokenType.FROMUNIXTIME_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr unixTime = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                unixTime
            });
        }

        if (match(new List<TokenType>{
            TokenType.NOW_FN, TokenType.TODAY_FN, TokenType.TIMENOW_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>());
        }

        if (match(TokenType.ROUND_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr numberValue = expression();

            // Optional number of digits to round to
            if (match(TokenType.COMMA)) {
                Expr numberOfDigits = expression();
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
                return new Expr.Function(fnName, new List<Expr>{
                    numberValue, numberOfDigits
                });
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                numberValue
            });
        }

        if (match(TokenType.TRUNC_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr value = expression();

            // Optional number of digits to truncate to
            if (match(TokenType.COMMA)) {
                Expr numberOfDigits = expression();
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
                return new Expr.Function(fnName, new List<Expr>{
                    value, numberOfDigits
                });
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                value
            });
        }

        if (match(TokenType.TOLIST_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr relationshipName = expression();
            consume(TokenType.COMMA, 'Expect \',\' after relationship name.');
            Expr fieldName = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                relationshipName, fieldName
            });
        }

        if (match(TokenType.AVERAGE_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr numberListValue = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                numberListValue
            });
        }

        if (match(TokenType.SIZE_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr listValue = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                listValue
            });
        }

        if (match(TokenType.LEFT_PAREN)) {
            Expr expr = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after expression.');
            return new Expr.Grouping(expr);
        }

        throw error(peek(), 'Expect expression.');
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

    private ParseException error(Token token, String message) {
        throw new ParseException(
            'Error at token ' + token.toString() + ': ' + message
        );
    }

    public class ParseException extends Exception {
    }
}
