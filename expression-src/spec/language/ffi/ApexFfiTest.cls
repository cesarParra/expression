@IsTest
private class ApexFfiTest {
    @IsTest
    private static void canUseCustomFunctions() {
        CustomFunctionRepository mockRepository = new MockFunctionRepository();
        CustomFunctionRepository.mockInstance = mockRepository;

        // This custom function concatenates the arguments.
        Object result = Evaluator.run('CUSTOMFUNCION("TestFormula", 1, 2)');
        Assert.areEqual('TestFormula12', result);
    }

    private class MockFunctionRepository extends CustomFunctionRepository {
        public override IExpressionFunction getByName(String functionName) {
            return new MockFunction();
        }
    }

    private class MockFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            String concatenated = '';
            for (Object arg : args) {
                concatenated += String.valueOf(arg);
            }
            return concatenated;
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenBubblingErrorsFromGlobalVariableResolvers() {
        try {
            Evaluator.run('$Action.Apex.NonExistentClass');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canInvokeCustomFunctions() {
        QDB.instance = new FakeExpressionFunctionRunner();
        String formula = 'CUSTOMFUNCTION()';
        Object result = Evaluator.run(formula);
        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void canPassCustomRecordContextInformationToCustomFunctions() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        QDB.instance = new FakeExpressionFunctionRunner();
        String formula = 'CUSTOMFUNCTION(Name)';
        Object result = Evaluator.run(formula, testAccount);
        Assert.areEqual('Hello Test Account', result);
    }

    private class FakeExpressionFunctionRunner extends QDB {
        public override List<SObject> run(Q query) {
            return new List<Expression_Function__mdt>{
                new Expression_Function__mdt(
                    Apex_Class__c = ApexFfiTest.FakeFunction.class.getName()
                )
            };
        }

        public override List<SObject> runRaw(String query) {
            return new List<SObject>();
        }

        public override void doInsert(SObject record) {
        }

        public override void doInsert(List<SObject> records) {
        }
    }

    public class FakeFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            if (args.isEmpty()) {
                return 'Test';
            }

            String arg = (String) args[0];
            return 'Hello ' + arg;
        }
    }
}
