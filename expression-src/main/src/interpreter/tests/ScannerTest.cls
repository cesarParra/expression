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
    static void tokensAreInCorrectPositionWhenThereAreStringsThatSpanLines() {
        Scanner scanner = new Scanner('"Hello\nWorld" & "!"');
        List<Token> resultTokens = scanner.scanTokens();

        // String literal start
        System.assertEquals(1, resultTokens[0].position.lineStart);
        System.assertEquals(1, resultTokens[0].position.columnStart);
        System.assertEquals(2, resultTokens[0].position.columnEnd);

        // String literal
        System.assertEquals(1, resultTokens[1].position.lineStart);
        System.assertEquals(2, resultTokens[1].position.lineEnd);
        System.assertEquals(2, resultTokens[1].position.columnStart);
        System.assertEquals(6, resultTokens[1].position.columnEnd);

        // String literal end
        System.assertEquals(2, resultTokens[2].position.lineStart);
        System.assertEquals(6, resultTokens[2].position.columnStart);
        System.assertEquals(7, resultTokens[2].position.columnEnd);

        // Concatenation operator
//        System.assertEquals(2, resultTokens[2].position.lineStart);
//        System.assertEquals(10, resultTokens[2].position.columnStart);
//        System.assertEquals(13, resultTokens[2].position.columnEnd);

        // String literal start
        // TODO

        // String literal
        // TODO

        // String literal end
        // TODO
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
        Assert.areEqual(4, result.size());
        Assert.areEqual(TokenType.STRING_LITERAL_START, result[0].type);

        Assert.areEqual(TokenType.STRING_LITERAL, result[1].type);
        Assert.areEqual('abc', result[1].literal);

        Assert.areEqual(TokenType.STRING_LITERAL_END, result[2].type);
        Assert.areEqual(TokenType.EOF, result[3].type);
    }
}
