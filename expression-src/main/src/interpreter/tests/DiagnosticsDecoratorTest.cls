@IsTest
private class DiagnosticsDecoratorTest {
    @IsTest
    static void populatesDiagnosticsWhenRun() {
        String expression = '1 + 2';
        Configuration configWithDiagnostics = new Configuration();
        configWithDiagnostics.withDiagnostics = true;

        Object result = Evaluator.run(expression, configWithDiagnostics);

        Assert.areEqual(3, result);
        Assert.isNotNull(DiagnosticsDecorator.result.cpuTime);
        Assert.isNotNull(DiagnosticsDecorator.result.dmlStatements);
        Assert.isNotNull(DiagnosticsDecorator.result.queries);
        Assert.isNotNull(DiagnosticsDecorator.result.queryRows);
    }
}
