@IsTest
private class ParserTest {
    @IsTest
    static void parsesEmptyStrings() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.STRING_LITERAL_START, '"', null, null),
            new Token(TokenType.STRING_LITERAL_END, '"', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.StringLiteral.class);
        Assert.isTrue(((Expr.StringLiteral)result).stringsAndInterpolations.isEmpty());
    }

    @IsTest
    static void parsesStringWithCharacters() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.STRING_LITERAL_START, '"', null, null),
            new Token(TokenType.CHARACTER, 'a', 'a', null),
            new Token(TokenType.STRING_LITERAL_END, '"', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.StringLiteral.class);
        Assert.areEqual('a', ((Expr.StringLiteral)result).stringsAndInterpolations[0]);
    }

    @IsTest
    static void parsesStringWithInterpolation() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.STRING_LITERAL_START, '"', null, null),
            new Token(TokenType.CHARACTER, 'a', 'a', null),
            new Token(TokenType.STRING_INTERPOLATION_START, '${', null, null),
            new Token(TokenType.IDENTIFIER, 'b', null, null),
            new Token(TokenType.STRING_INTERPOLATION_END, '}', null, null),
            new Token(TokenType.STRING_LITERAL_END, '"', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.StringLiteral.class);
        Assert.areEqual(2, ((Expr.StringLiteral)result).stringsAndInterpolations.size());
        Assert.areEqual('a', ((Expr.StringLiteral)result).stringsAndInterpolations[0]);
        Assert.isInstanceOfType(((Expr.StringLiteral)result).stringsAndInterpolations[1], Expr.MergeField.class);
    }
}
