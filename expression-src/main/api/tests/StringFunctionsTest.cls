@IsTest
private class StringFunctionsTest {
    @IsTest
    private static void beginsFunctionReturnsTrueIfFirstArgumentBeginsWithSecondArgument() {
        Assert.areEqual(true, Evaluator.run('BEGINS("Hello World", "Hello")'));
    }

    @IsTest
    private static void beginsFunctionReturnsFalseIfFirstArgumentDoesNotBeginWithSecondArgument() {
        Assert.areEqual(false, Evaluator.run('BEGINS("Hello World", "World")'));
    }

    @IsTest
    private static void containsFunctionReturnsTrueIfFirstArgumentContainsSecondArgument() {
        Assert.areEqual(true, Evaluator.run('CONTAINS("Hello World", "llo Wo")'));
    }

    @IsTest
    private static void containsFunctionReturnsFalseIfFirstArgumentDoesNotContainSecondArgument() {
        Assert.areEqual(false, Evaluator.run('CONTAINS("Hello World", "Goodbye")'));
    }

    @IsTest
    private static void containsFunctionReturnsTrueIfAListContainsTheGivenValue() {
        Assert.areEqual(true, Evaluator.run('CONTAINS(LIST(1, 2, 3), 2)'));
    }

    @IsTest
    private static void containsFunctionReturnsFalseIfAListDoesNotContainTheGivenValue() {
        Assert.areEqual(false, Evaluator.run('CONTAINS(LIST(1, 2, 3), 4)'));
    }

    @IsTest
    private static void lowerFunctionReturnsLowercaseString() {
        Assert.areEqual('hello world', Evaluator.run('LOWER("Hello World")'));
    }

    @IsTest
    private static void findFunctionReturnsIndexOfSubstring() {
        Assert.areEqual(1, Evaluator.run('FIND("ello", "Hello")'));
    }

    @IsTest
    private static void findFunctionReturnsTheCorrectIndexWhenAStartingPositionIsSpecified() {
        Assert.areEqual(4, Evaluator.run('FIND("ab", "abcdabcd", 1)'));
    }

    @IsTest
    private static void findFunctionReturnsMinusOneWhenSubstringIsNotFound() {
        Assert.areEqual(-1, Evaluator.run('FIND("ab", "abcdabcd", 5)'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfValueIsNull() {
        Assert.areEqual('fallback', Evaluator.run('BLANKVALUE(null, "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsValueIfValueIsNotNull() {
        Assert.areEqual('value', Evaluator.run('BLANKVALUE("value", "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfStringIsBlank() {
        Assert.areEqual('fallback', Evaluator.run('BLANKVALUE("", "fallback")'));
    }

    @IsTest
    private static void leftFunctionReturnsLeftSubstring() {
        Assert.areEqual('Hello', Evaluator.run('LEFT("Hello World", 5)'));
    }

    @IsTest
    private static void isBlankReturnsTrueForAnEmptyString() {
        Assert.areEqual(true, Evaluator.run('ISBLANK("")'));
    }

    @IsTest
    private static void isBlankReturnsTrueForNull() {
        Assert.areEqual(true, Evaluator.run('ISBLANK(null)'));
    }

    @IsTest
    private static void lenFunctionReturnsLength() {
        Assert.areEqual(5, Evaluator.run('LEN("Hello")'));
    }

    @IsTest
    private static void lpadFunctionReturnsLeftPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('0001', Evaluator.run('LPAD("1", 4, "0")'));
    }

    @IsTest
    private static void lpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', Evaluator.run('LPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void lpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('   1', Evaluator.run('LPAD("1", 4)'));
    }

    @IsTest
    private static void rpadFunctionReturnsRightPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('1000', Evaluator.run('RPAD("1", 4, "0")'));
    }

    @IsTest
    private static void rpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', Evaluator.run('RPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void rpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('1   ', Evaluator.run('RPAD("1", 4)'));
    }

    @IsTest
    private static void midFunctionCanReturnsFromTheBeginningOfTheStringWhenTheFirstArgumentIs1() {
        Assert.areEqual('abc', Evaluator.run('MID("abc", 1, 3)'));
    }

    @IsTest
    private static void midFunctionReturnsASubstringBeginningAtTheSpecifiedPosition() {
        Assert.areEqual('b', Evaluator.run('MID("abc", 2, 1)'));
    }

    @IsTest
    private static void substringFunctionReturnsASubstringBeginningAtTheSpecifiedPosition() {
        Assert.areEqual('bc', Evaluator.run('SUBSTRING("abc", 2, 2)'));
    }

    @IsTest
    private static void substringFunctionReturnsASubstringBeginningAtTheSpecifiedPositionWhenTheFirstArgumentIs1() {
        Assert.areEqual('abc', Evaluator.run('SUBSTRING("abc", 1, 3)'));
    }

    @IsTest
    private static void substringFunctionReturnsTheEntireStringBeginningAtTheSpecifiedPositionWhenTheThirdArgumentIsOmitted() {
        Assert.areEqual('bc', Evaluator.run('SUBSTRING("abc", 2)'));
    }

    @IsTest
    private static void rightFunctionReturnsRightSubstring() {
        Assert.areEqual('World', Evaluator.run('RIGHT("Hello World", 5)'));
    }

    @IsTest
    private static void rightFunctionWith0LengthReturnsAnEmptyString() {
        Assert.areEqual('', Evaluator.run('RIGHT("Hello World", 0)'));
    }

    @IsTest
    private static void rightFunctionWithLessThanZeroLengthReturnsAnEmptyString() {
        Assert.areEqual('', Evaluator.run('RIGHT("Hello World", -1)'));
    }

    @IsTest
    private static void brFunAdds1LineBreakWhenNoArgumentsArePassed() {
        Assert.areEqual('a\nb', Evaluator.run('"a" + BR() + "b"'));
    }

    @IsTest
    private static void brFunAdds1LineBreakWhen1ArgumentIsPassed() {
        Assert.areEqual('a\n\nb', Evaluator.run('"a" + BR(2) + "b"'));
    }

    @IsTest
    private static void hyperlinkBuildsAnAnchorTag() {
        Assert.areEqual('<a href="https://www.google.com">Google</a>', Evaluator.run('HYPERLINK("https://www.google.com", "Google")'));
    }

    @IsTest
    private static void hyperLinkCanReceiveTheTargetAsAThirdParameters() {
        Assert.areEqual('<a href="https://www.google.com" target="_blank">Google</a>', Evaluator.run('HYPERLINK("https://www.google.com", "Google", "_blank")'));
    }

    @IsTest
    private static void substituteReplacesAllOccurrencesOfTheFirstArgumentWithTheSecondArgument() {
        Assert.areEqual('Heyo World', Evaluator.run('SUBSTITUTE("Hello World", "ll", "y")'));
    }

    @IsTest
    private static void textConvertsNumbersToString() {
        Assert.areEqual('1', Evaluator.run('TEXT(1)'));
    }

    @IsTest
    private static void textConvertsDateValues() {
        Assert.areEqual('1/1/2015', Evaluator.run('TEXT(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void textConvertsDateTimeValues() {
        Assert.areEqual('1/1/2015, 12:00 AM', Evaluator.run('TEXT(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void textConvertsFalseValues() {
        Assert.areEqual('false', Evaluator.run('TEXT(false)'));
    }

    @IsTest
    private static void textConvertsTrueValues() {
        Assert.areEqual('true', Evaluator.run('TEXT(true)'));
    }

    @IsTest
    private static void textConvertsTimeValues() {
        Assert.areEqual('12:00:00 AM', Evaluator.run('TEXT(TIMEVALUE("00:00:00"))'));
    }

    @IsTest
    private static void trimFunctionRemovesLeadingAndTrailingWhitespace() {
        Assert.areEqual('Hello World', Evaluator.run('TRIM("  Hello World  ")'));
    }

    @IsTest
    private static void upperFunctionConvertsToUppercase() {
        Assert.areEqual('HELLO WORLD', Evaluator.run('UPPER("Hello World")'));
    }

    @IsTest
    private static void reverseFunctionReversesAString() {
        Assert.areEqual('cba', Evaluator.run('REVERSE("abc")'));
    }

    @IsTest
    private static void valueFunctionConvertsAStringToANumber() {
        Assert.areEqual(1, Evaluator.run('VALUE("1")'));
    }

    @IsTest
    private static void splitFunctionSplitsAString() {
        String formula = 'SPLIT("a,b,c", ",")';
        Object result = Evaluator.run(formula);
        Assert.areEqual(3, ((List<Object>) result).size());
        Assert.areEqual('a', ((List<Object>) result)[0]);
        Assert.areEqual('b', ((List<Object>) result)[1]);
        Assert.areEqual('c', ((List<Object>) result)[2]);
    }

    @IsTest
    private static void initCapFunctionCapitalizesTheFirstLetterOfEachWord() {
        String formula = 'INITCAP("hELLO world")';
        Object result = Evaluator.run(formula);
        Assert.areEqual('Hello World', result);
    }
}
