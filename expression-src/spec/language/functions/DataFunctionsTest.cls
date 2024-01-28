@IsTest
private class DataFunctionsTest {
    @IsTest
    private static void transformFunctionCanConvertFromOneObjectToAnyOther() {
        String formula = 'TRANSFORM("a", UPPER($source))';
        Object result = Evaluator.run(formula);
        Assert.areEqual('A', result);
    }

    @IsTest
    private static void letFunctionAllowsForVariablesToBeDefined() {
        String formula = 'LET({"$a": 1, "$b": 2},  $a + $b)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(3, result);
    }
}
