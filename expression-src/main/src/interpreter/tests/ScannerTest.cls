@IsTest
private class ScannerTest {
    @IsTest
    static void singleCharacterHasTheCorrectPosition() {
        Scanner scanner = new Scanner('a');
        Token resultToken = scanner.scanTokens()[0];
        System.assertEquals(1, resultToken.position.lineStart);
        System.assertEquals(1, resultToken.position.columnStart);
        System.assertEquals(2, resultToken.position.columnEnd);
    }

    @IsTest
    static void singleLineTokensAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1 + 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        System.assertEquals(1, resultTokens[1].position.lineStart);
        System.assertEquals(3, resultTokens[1].position.columnStart);
        System.assertEquals(4, resultTokens[1].position.columnEnd);

        System.assertEquals(1, resultTokens[2].position.lineStart);
        System.assertEquals(5, resultTokens[2].position.columnStart);
        System.assertEquals(6, resultTokens[2].position.columnEnd);
    }

    @IsTest
    static void multiLineTokensAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1\n+\n1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        System.assertEquals(2, resultTokens[1].position.lineStart);
        System.assertEquals(1, resultTokens[1].position.columnStart);
        System.assertEquals(2, resultTokens[1].position.columnEnd);

        System.assertEquals(3, resultTokens[2].position.lineStart);
        System.assertEquals(1, resultTokens[2].position.columnStart);
        System.assertEquals(2, resultTokens[2].position.columnEnd);
    }

    @IsTest
    static void multiLineTokensWithSpacesInBetweenAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1\n +\n 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        System.assertEquals(2, resultTokens[1].position.lineStart);
        System.assertEquals(2, resultTokens[1].position.columnStart);
        System.assertEquals(3, resultTokens[1].position.columnEnd);

        System.assertEquals(3, resultTokens[2].position.lineStart);
        System.assertEquals(2, resultTokens[2].position.columnStart);
        System.assertEquals(3, resultTokens[2].position.columnEnd);
    }

    @IsTest
    static void tokensAreInTheCorrectPlaceWhenThereAreBlankLinesAtTheBeginning() {
        Scanner scanner = new Scanner('\n\n1 + 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(3, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        System.assertEquals(3, resultTokens[1].position.lineStart);
        System.assertEquals(3, resultTokens[1].position.columnStart);
        System.assertEquals(4, resultTokens[1].position.columnEnd);

        System.assertEquals(3, resultTokens[2].position.lineStart);
        System.assertEquals(5, resultTokens[2].position.columnStart);
        System.assertEquals(6, resultTokens[2].position.columnEnd);
    }

    @IsTest
    static void scansEmptyStrings() {
        String expression = '""';
        List<Token> result = new Scanner(expression).scanTokens();
        Assert.areEqual(3, result.size());
        Assert.areEqual(TokenType.STRING_LITERAL_START, result[0].type);
        Assert.areEqual(TokenType.STRING_LITERAL_END, result[1].type);
        Assert.areEqual(TokenType.EOF, result[2].type);
    }

    @IsTest
    static void scansStringWithCharacters() {
        String expression = '"abc"';
        List<Token> result = new Scanner(expression).scanTokens();
        Assert.areEqual(6, result.size());

        Assert.areEqual(TokenType.STRING_LITERAL_START, result[0].type);
        Assert.areEqual(TokenType.CHARACTER, result[1].type);
        Assert.areEqual('a', result[1].literal);
        Assert.areEqual(TokenType.CHARACTER, result[2].type);
        Assert.areEqual('b', result[2].literal);
        Assert.areEqual(TokenType.CHARACTER, result[3].type);
        Assert.areEqual('c', result[3].literal);
        Assert.areEqual(TokenType.STRING_LITERAL_END, result[4].type);
        Assert.areEqual(TokenType.EOF, result[5].type);
    }

    @IsTest
    static void tokensAreInCorrectPositionWhenThereAreStringsThatSpanLines() {
        Scanner scanner = new Scanner('"Hi\nU" & "!"');
        List<Token> resultTokens = scanner.scanTokens();

        // String literal start
        System.assertEquals(1, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        // Character H
        System.assertEquals(1, resultTokens[1].position.lineStart);
        System.assertEquals(2, resultTokens[1].position.columnStart);
        System.assertEquals(3, resultTokens[1].position.columnEnd);

        // Character i
        System.assertEquals(1, resultTokens[2].position.lineStart);
        System.assertEquals(3, resultTokens[2].position.columnStart);
        System.assertEquals(4, resultTokens[2].position.columnEnd);

        // Character \n
        System.assertEquals(2, resultTokens[3].position.lineStart);
        System.assertEquals(0, resultTokens[3].position.columnStart);
        System.assertEquals(1, resultTokens[3].position.columnEnd);

        // Character U
        System.assertEquals(2, resultTokens[4].position.lineStart);
        System.assertEquals(1, resultTokens[4].position.columnStart);
        System.assertEquals(2, resultTokens[4].position.columnEnd);

        // String literal end
        System.assertEquals(2, resultTokens[5].position.lineStart);
        System.assertEquals(2, resultTokens[5].position.columnStart);
        System.assertEquals(3, resultTokens[5].position.columnEnd);

        // Concatenation operator
        System.assertEquals(2, resultTokens[6].position.lineStart);
        System.assertEquals(4, resultTokens[6].position.columnStart);
        System.assertEquals(5, resultTokens[6].position.columnEnd);

        // String literal start
        System.assertEquals(2, resultTokens[7].position.lineStart);
        System.assertEquals(6, resultTokens[7].position.columnStart);
        System.assertEquals(7, resultTokens[7].position.columnEnd);

        // Character !
        System.assertEquals(2, resultTokens[8].position.lineStart);
        System.assertEquals(7, resultTokens[8].position.columnStart);
        System.assertEquals(8, resultTokens[8].position.columnEnd);

        // String literal end
        System.assertEquals(2, resultTokens[9].position.lineStart);
        System.assertEquals(8, resultTokens[9].position.columnStart);
        System.assertEquals(9, resultTokens[9].position.columnEnd);
    }

    @IsTest
    private static void canScanStringInterpolations() {
        String expression = '"Hi ${name}"';
        List<Token> result = new Scanner(expression).scanTokens();

        Assert.areEqual(9, result.size());
        Assert.areEqual(TokenType.STRING_LITERAL_START, result[0].type);
        Assert.areEqual(TokenType.CHARACTER, result[1].type);
        Assert.areEqual('H', result[1].literal);
        Assert.areEqual(TokenType.CHARACTER, result[2].type);
        Assert.areEqual('i', result[2].literal);
        Assert.areEqual(TokenType.CHARACTER, result[3].type);
        Assert.areEqual(' ', result[3].literal);
        Assert.areEqual(TokenType.STRING_INTERPOLATION_START, result[4].type);
        Assert.areEqual(TokenType.IDENTIFIER, result[5].type);
        Assert.areEqual('name', result[5].lexeme);
        Assert.areEqual(TokenType.STRING_INTERPOLATION_END, result[6].type);
        Assert.areEqual(TokenType.STRING_LITERAL_END, result[7].type);
        Assert.areEqual(TokenType.EOF, result[8].type);
    }
}
