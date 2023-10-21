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

    // parses strings with characters
    @IsTest
    static void parsesStringWithCharacters() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.STRING_LITERAL_START, '"', null, null),
            new Token(TokenType.STRING_LITERAL, 'abc', 'abc', null),
            new Token(TokenType.STRING_LITERAL_END, '"', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.StringLiteral.class);
        Assert.areEqual('abc', ((Expr.StringLiteral)result).stringsAndInterpolations[0]);
    }
}
