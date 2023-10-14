@IsTest
private class ScannerTest {
    @IsTest
    static void singleCharacterHasTheCorrectPosition() {
        Scanner scanner = new Scanner('a');
        Token resultToken = scanner.scanTokens()[0];
        System.assertEquals(1, resultToken.position.line);
        System.assertEquals(1, resultToken.position.column);
    }

    @IsTest
    static void singleLineTokensAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1 + 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.line);
        System.assertEquals(1, resultTokens[0].position.column);

        System.assertEquals(1, resultTokens[1].position.line);
        System.assertEquals(3, resultTokens[1].position.column);

        System.assertEquals(1, resultTokens[2].position.line);
        System.assertEquals(5, resultTokens[2].position.column);
    }

    @IsTest
    static void multiLineTokensAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1\n+\n1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.line);
        System.assertEquals(1, resultTokens[0].position.column);

        System.assertEquals(2, resultTokens[1].position.line);
        System.assertEquals(1, resultTokens[1].position.column);

        System.assertEquals(3, resultTokens[2].position.line);
        System.assertEquals(1, resultTokens[2].position.column);
    }

    @IsTest
    static void multiLineTokensWithSpacesInBetweenAreInTheCorrectPlace() {
        Scanner scanner = new Scanner('1\n +\n 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.line);
        System.assertEquals(1, resultTokens[0].position.column);

        System.assertEquals(2, resultTokens[1].position.line);
        System.assertEquals(2, resultTokens[1].position.column);

        System.assertEquals(3, resultTokens[2].position.line);
        System.assertEquals(2, resultTokens[2].position.column);
    }

    @IsTest
    static void tokensAreInCorrectPositionWhenThereAreStringsThatSpanLines() {
        Scanner scanner = new Scanner('"Hello\nWorld" & "!"');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(1, resultTokens[0].position.line);
        System.assertEquals(1, resultTokens[0].position.column);

        System.assertEquals(2, resultTokens[1].position.line);
        System.assertEquals(8, resultTokens[1].position.column);

        System.assertEquals(2, resultTokens[2].position.line);
        System.assertEquals(10, resultTokens[2].position.column);
    }

    @IsTest
    static void tokensAreInTheCorrectPlaceWhenThereAreBlankLinesAtTheBeginning() {
        Scanner scanner = new Scanner('\n\n1 + 1');
        List<Token> resultTokens = scanner.scanTokens();

        System.assertEquals(3, resultTokens[0].position.line);
        System.assertEquals(1, resultTokens[0].position.column);

        System.assertEquals(3, resultTokens[1].position.line);
        System.assertEquals(3, resultTokens[1].position.column);

        System.assertEquals(3, resultTokens[2].position.line);
        System.assertEquals(5, resultTokens[2].position.column);
    }
}
