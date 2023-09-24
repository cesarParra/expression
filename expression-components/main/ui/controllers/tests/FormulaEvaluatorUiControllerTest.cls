@IsTest
private class FormulaEvaluatorUiControllerTest {
    @IsTest
    static void evaluateWithRecordIdReturnsEvaluatedFormula() {
        Id recordId = IdGenerator.generate(Account.SObjectType);
        Object result = FormulaEvaluatorUiController.evaluate(recordId, '1 + 1');
        Assert.areEqual(2, result);
    }

    @IsTest
    static void evaluateWithoutRecordIdReturnsEvaluatedFormula() {
        Object result = FormulaEvaluatorUiController.evaluate(null, '1 + 1');
        Assert.areEqual(2, result);
    }

    @IsTest
    static void whenAnErrorOccursAnAuraHandledExceptionIsThrown() {
        try {
            FormulaEvaluatorUiController.evaluate(null, '1 + 1 +');
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, AuraHandledException.class);
        }
    }
}
