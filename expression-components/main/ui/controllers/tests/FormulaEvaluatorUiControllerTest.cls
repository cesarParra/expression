@IsTest
private class FormulaEvaluatorUiControllerTest {
    @IsTest
    static void evaluateWithRecordIdReturnsEvaluatedFormula() {
        Id recordId = IdGenerator.generate(Account.SObjectType);
        Object result = FormulaEvaluatorUiController.evaluate(recordId, '1 + 1', true);
        Assert.areEqual(2, result);
    }

    @IsTest
    static void evaluateWithoutRecordIdReturnsEvaluatedFormula() {
        Object result = FormulaEvaluatorUiController.evaluate(null, '1 + 1', true);
        Assert.areEqual(2, result);
    }

    @IsTest
    static void whenAnErrorOccursDuringEvaluationAnAuraHandledExceptionIsThrown() {
        try {
            FormulaEvaluatorUiController.evaluate(null, '1 + 1 +', true);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, AuraHandledException.class);
        }
    }

    @IsTest
    static void canExecuteAReceivedFunctionReference() {
        Map<String, Object> functionReference = new Map<String, Object>{
            'class' => TestFunction.class.getName(),
            'arguments' => new List<Object>{ 1, 2 }
        };

        Object result = FormulaEvaluatorUiController.execute(functionReference);
        Assert.areEqual(3, result);
    }

    public class TestFunction implements IExpressionFunction {
        public Object execute(List<Object> arguments) {
            return 3;
        }
    }

    @IsTest
    static void whenAnErrorOccursDuringExecutionAnAuraHandledExceptionIsThrown() {
        Map<String, Object> functionReference = new Map<String, Object>{
            'class' => TestFunctionWithError.class.getName(),
            'arguments' => new List<Object>{ 1, 2 }
        };

        try {
            FormulaEvaluatorUiController.execute(functionReference);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, AuraHandledException.class);
        }
    }

    public class TestFunctionWithError implements IExpressionFunction {
        public Object execute(List<Object> arguments) {
            throw new UnsupportedOperationException('Test');
        }
    }
}
