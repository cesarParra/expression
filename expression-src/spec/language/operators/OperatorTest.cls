@IsTest
private class OperatorTest {
    @IsTest
    private static void supportsAddition_2Numbers() {
        Assert.areEqual(3, Evaluator.run('1 + 2'));
    }

    @IsTest
    private static void supportsAddition_3Numbers() {
        Assert.areEqual(6, Evaluator.run('1 + 2 + 3'));
    }

    @IsTest
    private static void supportsStringConcatenation_plus() {
        Assert.areEqual('abc', Evaluator.run('"a" + "b" + "c"'));
    }

    @IsTest
    private static void supportsStringConcatenation_ampersand() {
        Assert.areEqual('abc', Evaluator.run('"a" & "b" & "c"'));
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenConcatenatingNonStrings_usingAmp() {
        try {
            Evaluator.run('"a" & 1');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenConcatenatingNonStrings_usingPlus() {
        try {
            Evaluator.run('"a" + 1');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void supportsSubtraction() {
        Assert.areEqual(1, Evaluator.run('2 - 1'));
    }

    @IsTest
    private static void supportsMultiplication() {
        Assert.areEqual(6, Evaluator.run('2 * 3'));
    }

    @IsTest
    private static void supportsDivision() {
        Assert.areEqual(2, Evaluator.run('6 / 3'));
    }

    @IsTest
    private static void supportsExponentiation() {
        Assert.areEqual(8, Evaluator.run('2 ^ 3'));
    }

    @IsTest
    private static void throwsRuntimeWhenUsingExpOnNonNumbers() {
        try {
            Evaluator.run('"a" ^ 2');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void supportsEquality_singleEqualCharacter() {
        Assert.areEqual(true, Evaluator.run('1 = 1'));
    }

    @IsTest
    private static void supportsEquality_doubleEqualCharacter() {
        Assert.areEqual(true, Evaluator.run('1 == 1'));
    }

    @IsTest
    private static void supportsInequality_bangEqual() {
        Assert.areEqual(true, Evaluator.run('1 != 2'));
    }

    @IsTest
    private static void supportsInequality_lessThanGreaterThan() {
        Assert.areEqual(true, Evaluator.run('1 <> 2'));
    }

    @IsTest
    private static void supportsLessThan() {
        Assert.areEqual(true, Evaluator.run('1 < 2'));
    }

    @IsTest
    private static void supportsLessThanOrEqual() {
        Assert.areEqual(true, Evaluator.run('1 <= 2'));
    }

    @IsTest
    private static void supportsGreaterThan() {
        Assert.areEqual(true, Evaluator.run('2 > 1'));
    }

    @IsTest
    private static void supportsGreaterThanOrEqual() {
        Assert.areEqual(true, Evaluator.run('2 >= 1'));
    }

    @IsTest
    private static void andHasCorrectPrecedence() {
        Assert.areEqual(true, Evaluator.run('1 = 1 && 2 = 2 || 3 = 3'));
    }

    @IsTest
    private static void supportsAnd_withGrouping() {
        Assert.areEqual(true, Evaluator.run('1 = 1 && (2 = 2)'));
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenLeftSideOfDoubleAmpIsNotBoolean() {
        try {
            Evaluator.run('1 && 2');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenRightSideOfDoubleAmpIsNotBoolean() {
        try {
            Evaluator.run('1 = 1 && 2');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void supportsAnd_leftFalse() {
        Assert.areEqual(false, Evaluator.run('1 = 2 && 2 = 2'));
    }

    @IsTest
    private static void supportsAnd_rightFalse() {
        Assert.areEqual(false, Evaluator.run('1 = 1 && (2 = 3)'));
    }

    @IsTest
    private static void supportsAnd_withOr() {
        Assert.areEqual(true, Evaluator.run('((1 = 1) && (2 = 2)) || (3 = 3)'));
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenLeftSideOfDoublePipeIsNotBoolean() {
        try {
            Evaluator.run('1 || 2');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenRightSideOfDoublePipeIsNotBoolean() {
        try {
            Evaluator.run('1 != 1 || 2');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void supportsOr() {
        Assert.areEqual(true, Evaluator.run('1 = 1 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_leftFalse() {
        Assert.areEqual(true, Evaluator.run('1 = 2 || (2 = 2)'));
    }

    @IsTest
    private static void supportsOr_rightFalse() {
        Assert.areEqual(true, Evaluator.run('1 = 1 || (2 = 3)'));
    }

    @IsTest
    private static void supportsNegatingExpression() {
        Assert.areEqual(false, Evaluator.run('!(1=1)'));
    }

    @IsTest
    private static void supportsMinusBeforeNumber() {
        Assert.areEqual(-1, Evaluator.run('-1'));
    }

    @IsTest
    private static void supportsParentheses_toTheLeft() {
        Assert.areEqual(9, Evaluator.run('(1 + 2) * 3'));
    }

    @IsTest
    private static void supportsParentheses_toTheRight() {
        Assert.areEqual(9, Evaluator.run('3 * (1 + 2)'));
    }
}
