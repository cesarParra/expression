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

    @IsTest
    private static void spreadOperatorExpandsAList() {
        Assert.areEqual(3, Evaluator.run('SIZE([...LIST(1, 2, 3)])'));
    }

    @IsTest
    private static void spreadOperatorsCanBeNested() {
        String formula = '[...[1, 2], ...[3, 4], ...[5, 6]]';
        List<Object> result = (List<Object>)Evaluator.run(formula);
        Assert.areEqual(6, result.size());
        for (Integer i = 0; i < 6; i++) {
            Assert.areEqual(i + 1, result[i]);
        }
    }

    @IsTest
    private static void spreadOperatorCanBeUsedInsideOfAListFunction() {
        Assert.areEqual(3, Evaluator.run('SIZE(LIST(...LIST(1, 2, 3)))'));
        Assert.areEqual(6, Evaluator.run('SIZE(LIST(1, 2, 3, ...[4, 5, 6]))'));
    }

    @IsTest
    private static void mapsSupportTheSpreadOperator() {
        Map<Object, Object> result = (Map<Object, Object>)Evaluator.run('{...{"a": 1, "b": 2}}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    private static void spreadOperatorsInMapsCanBeNested() {
        Map<Object, Object> result = (Map<Object, Object>)Evaluator.run('{...{"a": 1, "b": 2}, ...{"c": 3, "d": 4}}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
        Assert.areEqual(3, result.get('c'));
        Assert.areEqual(4, result.get('d'));
    }

    @IsTest
    private static void spreadOperatorInMapRespectTheRightmostValue() {
        Map<Object, Object> result = (Map<Object, Object>)Evaluator.run('{...{"a": 1, "b": 2}, "b": 3}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(3, result.get('b'));
    }

    @IsTest
    private static void canPipeFunctionCalls() {
        Assert.areEqual(3, Evaluator.run('LIST(1, 2, 3) -> SIZE()'));
    }

    @IsTest
    private static void canPipeFunctionCalls_pipeHasPrecedenceWhenPairedWithOtherExpressions() {
        Assert.areEqual(8, Evaluator.run('LIST(1, 2, 3) -> SIZE() + 5'));
    }

    @IsTest
    private static void canPipeFunctionCallsMultipleTimes() {
        Object result = Evaluator.run('[1, 2, 3, 4, 5, 6] -> WHERE($current > 2) -> WHERE($current < 5)');
        Assert.areEqual(2, ((List<Object>)result).size());
        Assert.areEqual(3, ((List<Object>)result)[0]);
        Assert.areEqual(4, ((List<Object>)result)[1]);
    }

    @IsTest
    private static void canCapturePipedValues() {
        Object result = Evaluator.run(
            'RANGE(1, 10)\n' +
                '-> WHERE(_, $current > 4)\n' +
                '-> SUM()'
        );
        Assert.areEqual(45, result);
    }

    @IsTest
    private static void canSpreadACapturedValue() {
        Object result = Evaluator.run(
            'RANGE(1, 5)\n' +
                '-> WHERE(_, $current > 2)\n' +
                '-> [..._]'
        );
        List<Object> resultList = (List<Object>)result;
        Assert.areEqual(3, resultList.size());
        Assert.areEqual(3, resultList[0]);
        Assert.areEqual(4, resultList[1]);
        Assert.areEqual(5, resultList[2]);
    }

    @IsTest
    private static void canUseACapturedValueSeveralTimes() {
        Object result = Evaluator.run(
            'RANGE(1, 3)\n' +
                '-> WHERE(_, $current > 1)\n' +
                '-> SUM(_) + SIZE(_)'
        );
        Assert.areEqual(7, result);
    }

    @IsTest
    private static void canUseASpreadValueInANonFunctionCall() {
        Object result = Evaluator.run(
            'RANGE(1, 3)\n' +
                '-> WHERE(_, $current > 1)\n' +
                '-> 10 + SIZE(_)'
        );

        Assert.areEqual(12, result);
    }
}
