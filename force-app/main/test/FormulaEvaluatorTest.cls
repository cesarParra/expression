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
}
