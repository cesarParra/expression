@IsTest
private class LogicalFunctionsTest {
    @IsTest
    private static void canEvaluateAndFunctionWith2Arguments() {
        Assert.areEqual(true, Evaluator.run('AND(true, true)'));
    }

    @IsTest
    private static void canEvaluateAndFunctionWithMoreThan2Arguments() {
        Assert.areEqual(true, Evaluator.run('AND(true, true, true)'));
    }

    @IsTest
    private static void andFunctionWithAnyFalseReturnsFalse() {
        Assert.areEqual(false, Evaluator.run('AND(true, false, true)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesFirstArgumentWhenTrue() {
        Assert.areEqual(1, Evaluator.run('IF(true, 1, 2)'));
    }

    @IsTest
    private static void ifFunctionEvaluatesSecondArgumentWhenFalse() {
        Assert.areEqual(2, Evaluator.run('IF(false, 1, 2)'));
    }

    @IsTest
    private static void notFunctionNegatesATrueExpression() {
        Assert.areEqual(false, Evaluator.run('NOT(1=1)'));
    }

    @IsTest
    private static void notFunctionNegatesAFalseExpression() {
        Assert.areEqual(true, Evaluator.run('NOT(1=2)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAllArgumentsAreTrue() {
        Assert.areEqual(true, Evaluator.run('OR(true, true, true)'));
    }

    @IsTest
    private static void orFunctionReturnsTrueIfAnyArgumentIsTrue() {
        Assert.areEqual(true, Evaluator.run('OR(true, false, false)'));
    }

    @IsTest
    private static void orFunctionReturnsFalseIfAllArgumentsAreFalse() {
        Assert.areEqual(false, Evaluator.run('OR(false, false, false)'));
    }

    @IsTest
    private static void caseFunctionReturnsTheCorrectValueWhenThereIsAMatch() {
        Account testAccount = new Account(Rating = 'Hot');

        Object result = Evaluator.run('CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")', testAccount);

        Assert.areEqual('🔥', result);
    }

    @IsTest
    private static void caseFunctionReturnsElseValueWhenThereIsNoMatch() {
        Account testAccount = new Account(Rating = 'Warm');

        Object result = Evaluator.run('CASE(Rating, "Hot", "🔥", "Cold", "🧊", "🤷")', testAccount);

        Assert.areEqual('🤷', result);
    }
}
