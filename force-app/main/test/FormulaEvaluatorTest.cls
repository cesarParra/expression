@IsTest
private class FormulaEvaluatorTest {
    @IsTest
    private static void supportsNumberLiterals() {
        Assert.areEqual(100, FormulaEvaluator.evaluate('100'));
    }

    @IsTest
    private static void supportsStringLiterals() {
        Assert.areEqual('abc', FormulaEvaluator.evaluate('"abc"'));
    }

    @IsTest
    private static void supportsAddition_2Numbers() {
        Assert.areEqual(3, FormulaEvaluator.evaluate('1 + 2'));
    }

    @IsTest
    private static void supportsAddition_3Numbers() {
        Assert.areEqual(6, FormulaEvaluator.evaluate('1 + 2 + 3'));
    }

    @IsTest
    private static void supportsDecimalNumbers() {
        Assert.areEqual(1.5, FormulaEvaluator.evaluate('1.5'));
    }

    @IsTest
    private static void supportsStringConcatenation_plus() {
        Assert.areEqual('abc', FormulaEvaluator.evaluate('"a" + "b" + "c"'));
    }

    @IsTest
    private static void supportsStringConcatenation_ampersand() {
        Assert.areEqual('abc', FormulaEvaluator.evaluate('"a" & "b" & "c"'));
    }

    @IsTest
    private static void supportsSubtraction() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('2 - 1'));
    }

    @IsTest
    private static void supportsMultiplication() {
        Assert.areEqual(6, FormulaEvaluator.evaluate('2 * 3'));
    }

    @IsTest
    private static void supportsDivision() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('6 / 3'));
    }

    @IsTest
    private static void supportsExponentiation() {
        Assert.areEqual(8, FormulaEvaluator.evaluate('2 ^ 3'));
    }

    @IsTest
    private static void supportsParentheses_toTheLeft() {
        Assert.areEqual(9, FormulaEvaluator.evaluate('(1 + 2) * 3'));
    }

    @IsTest
    private static void supportsParentheses_toTheRight() {
        Assert.areEqual(9, FormulaEvaluator.evaluate('3 * (1 + 2)'));
    }

    @IsTest
    private static void supportsEquality_singleEqualCharacter() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 = 1'));
    }

    @IsTest
    private static void supportsEquality_doubleEqualCharacter() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 == 1'));
    }

    @IsTest
    private static void supportsInequality_bangEqual() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 != 2'));
    }

    @IsTest
    private static void supportsInequality_lessThanGreaterThan() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 <> 2'));
    }

    @IsTest
    private static void supportsLessThan() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 < 2'));
    }

    @IsTest
    private static void supportsLessThanOrEqual() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 <= 2'));
    }

    @IsTest
    private static void supportsGreaterThan() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('2 > 1'));
    }

    @IsTest
    private static void supportsGreaterThanOrEqual() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('2 >= 1'));
    }

    @IsTest
    private static void supportsAnd() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 = 1 && (2 = 2)'));
    }

    @IsTest
    private static void supportsAnd_leftFalse() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('1 = 2 && 2 = 2'));
    }

    @IsTest
    private static void supportsAnd_rightFalse() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('1 = 1 && (2 = 3)'));
    }

    @IsTest
    private static void supportsAnd_withOr() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('((1 = 1) && (2 = 2)) || (3 = 3)'));
    }

    @IsTest
    private static void supportsOr() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 = 1 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_leftFalse() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 = 2 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_rightFalse() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('1 = 1 || (2 = 3)'));
    }

    @IsTest
    private static void supportsNegatingExpression() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('!(1=1)'));
    }

    @IsTest
    private static void supportsMinusBeforeNumber() {
        Assert.areEqual(-1, FormulaEvaluator.evaluate('-1'));
    }

    @IsTest
    private static void supportsTrueLiterals() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('true'));
    }

    @IsTest
    private static void trueLiteralsAreCaseInsensitive() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('TRUE'));
    }

    @IsTest
    private static void supportsFalseLiterals() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('false'));
    }

    @IsTest
    private static void falseLiteralsAreCaseInsensitive() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('FALSE'));
    }

    @IsTest
    private static void supportsNullLiterals() {
        Assert.areEqual(null, FormulaEvaluator.evaluate('null'));
    }

    @IsTest
    private static void canEvaluateAndFunctionWith2Arguments() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('AND(true, true)'));
    }

    @IsTest
    private static void canEvaluateAndFunctionWithMoreThan2Arguments() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('AND(true, true, true)'));
    }

    @IsTest
    private static void andFunctionWithAnyFalseReturnsFalse() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('AND(true, false, true)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesFirstArgumentWhenTrue() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('IF(true, 1, 2)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesSecondArgumentWhenFalse() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('IF(false, 1, 2)'));
    }

    @IsTest
    private static void notFunctionNegatesATrueExpression() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('NOT(1=1)'));
    }

    @IsTest
    private static void notFunctionNegatesAFalseExpression() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('NOT(1=2)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAllArgumentsAreTrue() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('OR(true, true, true)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAnyArgumentIsTrue() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('OR(true, false, false)'));
    }

    @IsTest
    private static void orFunctionReturnsFalseIfAllArgumentsAreFalse() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('OR(false, false, false)'));
    }

    @IsTest
    private static void beginsFunctionReturnsTrueIfFirstArgumentBeginsWithSecondArgument() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('BEGINS("Hello World", "Hello")'));
    }

    @IsTest
    private static void beginsFunctionReturnsFalseIfFirstArgumentDoesNotBeginWithSecondArgument() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('BEGINS("Hello World", "World")'));
    }

    @IsTest
    private static void containsFunctionReturnsTrueIfFirstArgumentContainsSecondArgument() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('CONTAINS("Hello World", "llo Wo")'));
    }

    @IsTest
    private static void containsFunctionReturnsFalseIfFirstArgumentDoesNotContainSecondArgument() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('CONTAINS("Hello World", "Goodbye")'));
    }

    @IsTest
    private static void lowerFunctionReturnsLowercaseString() {
        Assert.areEqual('hello world', FormulaEvaluator.evaluate('LOWER("Hello World")'));
    }

    @IsTest
    private static void dateEvaluatesToADate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), FormulaEvaluator.evaluate('DATE(2015, 1, 1)'));
    }

    @IsTest
    private static void absFunctionReturnsAbsoluteValue() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('ABS(-1)'));
    }

    @IsTest
    private static void findFunctionReturnsIndexOfSubstring() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('FIND("ello", "Hello")'));
    }

    @IsTest
    private static void findFunctionReturnsTheCorrectIndexWhenAStartingPositionIsSpecified() {
        Assert.areEqual(4, FormulaEvaluator.evaluate('FIND("ab", "abcdabcd", 1)'));
    }

    @IsTest
    private static void findFunctionReturnsMinusOneWhenSubstringIsNotFound() {
        Assert.areEqual(-1, FormulaEvaluator.evaluate('FIND("ab", "abcdabcd", 5)'));
    }

    @IsTest
    private static void addMonthsFunctionAddsMonths() {
        Assert.areEqual(Date.newInstance(2015, 2, 1), FormulaEvaluator.evaluate('ADDMONTHS(DATE(2015, 1, 1), 1)'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfValueIsNull() {
        Assert.areEqual('fallback', FormulaEvaluator.evaluate('BLANKVALUE(null, "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsValueIfValueIsNotNull() {
        Assert.areEqual('value', FormulaEvaluator.evaluate('BLANKVALUE("value", "fallback")'));
    }

    @IsTest
    private static void blankValueReturnsFallbackIfStringIsBlank() {
        Assert.areEqual('fallback', FormulaEvaluator.evaluate('BLANKVALUE("", "fallback")'));
    }

    @IsTest
    private static void ceilingFunctionReturnsCeiling() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('CEILING(1.5)'));
    }

    @IsTest
    private static void leftFunctionReturnsLeftSubstring() {
        Assert.areEqual('Hello', FormulaEvaluator.evaluate('LEFT("Hello World", 5)'));
    }

    @IsTest
    private static void dayFunctionReturnsDay() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('DAY(DATE(2015, 1, 1))'));
    }

    @IsTest
    private static void isBlankReturnsTrueForAnEmptyString() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('ISBLANK("")'));
    }

    @IsTest
    private static void isBlankReturnsTrueForNull() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('ISBLANK(null)'));
    }

    @IsTest
    private static void floorFunctionReturnsFloor() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('FLOOR(1.5)'));
    }

    @IsTest
    private static void lenFunctionReturnsLength() {
        Assert.areEqual(5, FormulaEvaluator.evaluate('LEN("Hello")'));
    }

    @IsTest
    private static void dayOfYearFunctionReturnsDayOfYear() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('DAYOFYEAR(DATE(2015, 1, 1))'));
        Assert.areEqual(365, FormulaEvaluator.evaluate('DAYOFYEAR(DATE(2015, 12, 31))'));
    }

    @IsTest
    private static void fromUnixTimeFunctionReturnsADatetimeFromUnixTime() {
        Assert.areEqual(Datetime.newInstanceGmt(2015, 1, 1, 0, 0, 0), FormulaEvaluator.evaluate('FROMUNIXTIME(1420070400)'));
    }

    @IsTest
    private static void lpadFunctionReturnsLeftPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('0001', FormulaEvaluator.evaluate('LPAD("1", 4, "0")'));
    }

    @IsTest
    private static void lpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', FormulaEvaluator.evaluate('LPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void lpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('   1', FormulaEvaluator.evaluate('LPAD("1", 4)'));
    }

    @IsTest
    private static void rpadFunctionReturnsRightPaddedStringWhenTheDesiredLengthIsGreaterThanTheStringLength() {
        Assert.areEqual('1000', FormulaEvaluator.evaluate('RPAD("1", 4, "0")'));
    }

    @IsTest
    private static void rpadFunctionReturnsTheStringWhenTheDesiredLengthIsLessThanTheStringLength() {
        Assert.areEqual('1234', FormulaEvaluator.evaluate('RPAD("1234", 2, "0")'));
    }

    @IsTest
    private static void rpadFunctionPadsWithABlankStringWhenNo3rdArgumentIsSpecified() {
        Assert.areEqual('1   ', FormulaEvaluator.evaluate('RPAD("1", 4)'));
    }

    @IsTest
    private static void nowFunctionReturnsAValue() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(FormulaEvaluator.evaluate('NOW()'));
    }

    @IsTest
    private static void dateValueFunctionConvertsAStringToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), FormulaEvaluator.evaluate('DATEVALUE("2015-01-01")'));
    }

    @IsTest
    private static void dateValueFunctionConvertsADatetimeToDate() {
        Assert.areEqual(Date.newInstance(2015, 1, 1), FormulaEvaluator.evaluate('DATEVALUE(DATETIMEVALUE("2015-01-01 00:00:00"))'));
    }

    @IsTest
    private static void datetimeValueFunctionConvertsAStringToADatetime() {
        Assert.areEqual(Datetime.newInstance(2015, 1, 1, 0, 0, 0), FormulaEvaluator.evaluate('DATETIMEVALUE("2015-01-01 00:00:00")'));
    }

    @IsTest
    private static void canReferenceAMergeField() {
        Account account = new Account(Name = 'Test');
        Assert.areEqual('Test', FormulaEvaluator.evaluate('Name', account));
    }

    @IsTest
    private static void todayFunctionReturnsToday() {
        // Not asserting against a specific value because the value will change.
        Assert.isNotNull(FormulaEvaluator.evaluate('TODAY()'));
    }

    @IsTest
    private static void isNumberReturnsTrueForANumber() {
        Assert.areEqual(true, FormulaEvaluator.evaluate('ISNUMBER(1)'));
    }

    @IsTest
    private static void isNumberReturnsFalseForANonNumber() {
        Assert.areEqual(false, FormulaEvaluator.evaluate('ISNUMBER("1")'));
    }

    @IsTest
    private static void isNumberReturnsTrueForNumberMergeField() {
        Account account = new Account(NumberOfEmployees = 1);
        Assert.areEqual(true, FormulaEvaluator.evaluate('ISNUMBER(NumberOfEmployees)', account));
    }

    @IsTest
    private static void maxFunctionReturnsTheMaximumValue() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('MAX(1, 2)'));
    }

    @IsTest
    private static void maxFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(3, FormulaEvaluator.evaluate('MAX(1, 2, 3)'));
    }

    @IsTest
    private static void minFunctionReturnsTheMinimumValue() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('MIN(1, 2)'));
    }

    @IsTest
    private static void minFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('MIN(1, 2, 3)'));
    }

    @IsTest
    private static void reverseFunctionReversesAString() {
        Assert.areEqual('cba', FormulaEvaluator.evaluate('REVERSE("abc")'));
    }

    @IsTest
    private static void hourFunctionReturnsTheHourValueOfADateTime() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('HOUR(DATETIMEVALUE("2015-01-01 02:00:00"))'));
    }

    @IsTest
    private static void roundFunctionRoundsUp() {
        Assert.areEqual(2, FormulaEvaluator.evaluate('ROUND(1.5)'));
    }

    @IsTest
    private static void roundFunctionRoundsDown() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('ROUND(1.4)'));
    }

    @IsTest
    private static void roundFunctionAcceptsAnOptionalSecondArgument() {
        Assert.areEqual(1.5, FormulaEvaluator.evaluate('ROUND(1.45, 1)'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTime() {
        Assert.areEqual(Time.newInstance(2, 0, 0, 0), FormulaEvaluator.evaluate('TIMEVALUE(DATETIMEVALUE("2015-01-01 02:00:00"))'));
    }

    @IsTest
    private static void timeValueFunctionReturnsTheTimeValueOfADateTimeString() {
        Assert.areEqual(Time.newInstance(2, 0, 0, 0), FormulaEvaluator.evaluate('TIMEVALUE("2015-01-01 02:00:00")'));
    }

    @IsTest
    private static void truncFunctionTruncatesToTheSpecifiedNumberOfDigits() {
        Assert.areEqual(1.234, FormulaEvaluator.evaluate('TRUNC(1.2345, 3)'));
    }

    @IsTest
    private static void truncFunctionTruncatesToZeroDigits() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('TRUNC(1.2345, 0)'));
    }

    @IsTest
    private static void truncReturnsTheIntegerPartOfANumberWhenNo2ndArgumentIsSpecified() {
        Assert.areEqual(1, FormulaEvaluator.evaluate('TRUNC(1.2345)'));
    }

    @IsTest
    private static void midFunctionCanReturnsFromTheBeginningOfTheStringWhenTheFirstArgumentIs1() {
        Assert.areEqual('abc', FormulaEvaluator.evaluate('MID("abc", 1, 3)'));
    }

    @IsTest
    private static void midFunctionReturnsASubstringBeginningAtTheSpecifiedPosition() {
        Assert.areEqual('bc', FormulaEvaluator.evaluate('MID("abc", 2, 2)'));
    }
}
