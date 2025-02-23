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

    @IsTest
    static void parsesLocalVariables() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.DOLLAR, '$local', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.Variable.class);
        Expr.Variable variable = (Expr.Variable)result;
        Assert.areEqual('$local', variable.name.lexeme);
        Assert.areEqual(Expr.VariableType.LOCAL, variable.type);
    }

    @IsTest
    static void parsesContextualVariables() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.AT, '@Id', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.Variable.class);
        Expr.Variable variable = (Expr.Variable)result;
        Assert.areEqual('@Id', variable.name.lexeme);
        Assert.areEqual(Expr.VariableType.GLOBAL_CONTEXT, variable.type);
    }

    @IsTest
    static void parsesFunctionDeclarations() {
        List<Token> tokens = new List<Token> {
            new Token(TokenType.FUNCTION_KEYWORD, 'function', null, null),
            new Token(TokenType.IDENTIFIER, 'foo', null, null),
            new Token(TokenType.LEFT_PAREN, '(', null, null),
            new Token(TokenType.RIGHT_PAREN, ')', null, null),
            new Token(TokenType.FAT_ARROW, '=>', null, null),
            new Token(TokenType.IDENTIFIER, 'bar', null, null),
            new Token(TokenType.SEMICOLON, ';', null, null),
            new Token(TokenType.EOF, '', null, null)
        };

        Expr result = new Parser(tokens).parse();

        Assert.isInstanceOfType(result, Expr.FunctionDeclaration.class);
        Expr.FunctionDeclaration functionDeclaration = (Expr.FunctionDeclaration)result;
        Assert.areEqual('foo', functionDeclaration.name.lexeme);
    }

    @IsTest
    private static void throwsExceptionIfThereAreMoreTokensAfterTheEndOfACompleteExpression() {
        try {
            Evaluator.run('1 + 1 1');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.ParsingException.class);
        }
    }
}
