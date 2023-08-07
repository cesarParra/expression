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

        return primary();
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
            return new Expr.MergeField(previous());
        }

        if (match(new List<TokenType>{
                TokenType.AND_FN, TokenType.OR_FN, TokenType.MAX_FN, TokenType.MIN_FN
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

        if (match(TokenType.IF_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr condition = expression();
            consume(TokenType.COMMA, 'Expect \',\' after condition.');
            Expr thenBranch = expression();
            consume(TokenType.COMMA, 'Expect \',\' after then branch.');
            Expr elseBranch = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                    condition, thenBranch, elseBranch
            });
        }

        if (match(TokenType.NOT_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr condition = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                    condition
            });
        }

        if (match2(TokenType.BEGINS_FN, TokenType.CONTAINS_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after string.');
            Expr compareText = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                    text, compareText
            });
        }

        if (match(new List<TokenType>{
                TokenType.LOWER_FN, TokenType.LEN_FN, TokenType.REVERSE_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                    text
            });
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

        if (match(TokenType.FIND_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after text.');
            Expr findText = expression();

            // Optional start number to star looking from
            if (match(TokenType.COMMA)) {
                Expr startNumber = expression();
                return new Expr.Function(fnName, new List<Expr>{
                        text, findText, startNumber
                });
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    text, findText
            });
        }

        if (match(TokenType.ADDMONTHS_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr startDate = expression();
            consume(TokenType.COMMA, 'Expect \',\' after date.');
            Expr months = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    startDate, months
            });
        }

        if (match(TokenType.BLANKVALUE_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr value = expression();
            consume(TokenType.COMMA, 'Expect \',\' after value.');
            Expr valueIfBlank = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    value, valueIfBlank
            });
        }

        if (match(new List<TokenType>{
                TokenType.DAY_FN, TokenType.DAYOFYEAR_FN, TokenType.DATEVALUE_FN,
                TokenType.DATETIMEVALUE_FN, TokenType.HOUR_FN
        })) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr dateValue = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    dateValue
            });
        }

        if (match2(TokenType.ISBLANK_FN, TokenType.ISNUMBER_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr value = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    value
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

        if (match(TokenType.LEFT_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after text.');
            Expr numberOfCharacters = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    text, numberOfCharacters
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

        if (match2(TokenType.LPAD_FN, TokenType.RPAD_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after text.');
            Expr numberOfCharacters = expression();

            // The 3rd argument (pad string) is optional
            if (match(TokenType.COMMA)) {
                Expr padString = expression();
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

                return new Expr.Function(fnName, new List<Expr>{
                        text, numberOfCharacters, padString
                });
            }

            return new Expr.Function(fnName, new List<Expr>{
                    text, numberOfCharacters
            });
        }

        if (match2(TokenType.NOW_FN, TokenType.TODAY_FN)) {
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

        if (match(TokenType.MID_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after text.');
            Expr start = expression();
            consume(TokenType.COMMA, 'Expect \',\' after start.');
            Expr numberOfCharacters = expression();
            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');

            return new Expr.Function(fnName, new List<Expr>{
                    text, start, numberOfCharacters
            });
        }

        if (match(TokenType.SUBSTRING_FN)) {
            Token fnName = previous();
            consume(TokenType.LEFT_PAREN, 'Expect \'(\' after function name.');
            Expr text = expression();
            consume(TokenType.COMMA, 'Expect \',\' after text.');
            Expr start = expression();

            // Optional number of characters to extract
            if (match(TokenType.COMMA)) {
                Expr numberOfCharacters = expression();
                consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
                return new Expr.Function(fnName, new List<Expr>{
                        text, start, numberOfCharacters
                });
            }

            consume(TokenType.RIGHT_PAREN, 'Expect \')\' after parameters.');
            return new Expr.Function(fnName, new List<Expr>{
                    text, start
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
