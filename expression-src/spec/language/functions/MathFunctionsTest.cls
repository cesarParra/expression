@IsTest
private class MathFunctionsTest {
    @IsTest
    private static void absFunctionReturnsAbsoluteValue() {
        Assert.areEqual(1, Evaluator.run('ABS(-1)'));
    }

    @IsTest
    private static void ceilingFunctionReturnsCeiling() {
        Assert.areEqual(2, Evaluator.run('CEILING(1.5)'));
    }

    @IsTest
    private static void floorFunctionReturnsFloor() {
        Assert.areEqual(1, Evaluator.run('FLOOR(1.5)'));
    }

    @IsTest
    private static void isNumberReturnsTrueForANumber() {
        Assert.areEqual(true, Evaluator.run('ISNUMBER(1)'));
    }

    @IsTest
    private static void isNumberReturnsFalseForANonNumber() {
        Assert.areEqual(false, Evaluator.run('ISNUMBER("1")'));
    }

    @IsTest
    private static void isNumberReturnsTrueForNumberMergeField() {
        Account account = new Account(NumberOfEmployees = 1);
        Assert.areEqual(true, Evaluator.run('ISNUMBER(NumberOfEmployees)', account));
    }

    @IsTest
    private static void maxFunctionReturnsTheMaximumValue() {
        Assert.areEqual(2, Evaluator.run('MAX(1, 2)'));
    }

    @IsTest
    private static void maxFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(3, Evaluator.run('MAX(1, 2, 3)'));
    }

    @IsTest
    private static void minFunctionReturnsTheMinimumValue() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2)'));
    }

    @IsTest
    private static void minFunctionAcceptsMoreThanTwoArguments() {
        Assert.areEqual(1, Evaluator.run('MIN(1, 2, 3)'));
    }

    @IsTest
    private static void roundFunctionRoundsUp() {
        Assert.areEqual(2, Evaluator.run('ROUND(1.5)'));
    }

    @IsTest
    private static void roundFunctionRoundsDown() {
        Assert.areEqual(1, Evaluator.run('ROUND(1.4)'));
    }

    @IsTest
    private static void roundFunctionAcceptsAnOptionalSecondArgument() {
        Assert.areEqual(1.5, Evaluator.run('ROUND(1.45, 1)'));
    }

    @IsTest
    private static void truncFunctionTruncatesToTheSpecifiedNumberOfDigits() {
        Assert.areEqual(1.234, Evaluator.run('TRUNC(1.2345, 3)'));
    }

    @IsTest
    private static void truncFunctionTruncatesToZeroDigits() {
        Assert.areEqual(1, Evaluator.run('TRUNC(1.2345, 0)'));
    }

    @IsTest
    private static void truncReturnsTheIntegerPartOfANumberWhenNo2ndArgumentIsSpecified() {
        Assert.areEqual(1, Evaluator.run('TRUNC(1.2345)'));
    }

    @IsTest
    private static void modFunctionReturnsTheRemainderOfTheDivision() {
        Assert.areEqual(1, Evaluator.run('MOD(5, 2)'));
    }
}
