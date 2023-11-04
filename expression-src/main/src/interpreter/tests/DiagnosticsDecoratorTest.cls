// TODO: Rename and move to a more appropriate location
@IsTest
private class DiagnosticsDecoratorTest {
    @IsTest
    static void populatesDiagnosticsWhenRun() {
        String expression = '1 + 2';
        Configuration configWithDiagnostics = new Configuration().withDiagnostics();
        EvaluationResult result = EvaluatorResolver.withoutContext().evaluate(expression, configWithDiagnostics);

        Assert.isNotNull(result.additionalData.get('diagnostics'));

        EvaluationDiagnosticsListener.DiagnosticsResult diagnostics =
            (EvaluationDiagnosticsListener.DiagnosticsResult) result.additionalData.get('diagnostics');
        Assert.isNotNull(diagnostics.cpuTime);
        Assert.isNotNull(diagnostics.dmlStatements);
        Assert.isNotNull(diagnostics.queries);
        Assert.isNotNull(diagnostics.queryRows);
    }
}
