// TODO: Rename and move to a more appropriate location
@IsTest
private class DiagnosticsDecoratorTest {
    @IsTest
    static void populatesDiagnosticsWhenRun() {
        String expression = '1 + 2';
        Configuration configWithDiagnostics = new Configuration();
        configWithDiagnostics.withDiagnostics = true;

        Object result = Evaluator.run(expression, configWithDiagnostics);

        Assert.areEqual(3, result);
        Assert.isNotNull(EvaluationDiagnosticsListener.result.cpuTime);
        Assert.isNotNull(EvaluationDiagnosticsListener.result.dmlStatements);
        Assert.isNotNull(EvaluationDiagnosticsListener.result.queries);
        Assert.isNotNull(EvaluationDiagnosticsListener.result.queryRows);
    }
}
