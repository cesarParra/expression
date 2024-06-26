@IsTest
private class PlaygroundControllerTest {
    @IsTest
    static void getsTheExistingFunctionList() {
        List<String> functionNames = PlaygroundController.getFunctionNames();
        Assert.isFalse(functionNames.isEmpty());
    }

    @IsTest
    static void getCustomFunctions() {
        List<PlaygroundController.FunctionCategory> functionNames = PlaygroundController.getCustomFunctions();
        Assert.isFalse(functionNames.isEmpty());
    }

    @IsTest
    static void validatesAValidExpressionWithoutAnId() {
        PlaygroundController.Result result = PlaygroundController.validate(
            '1 + 1',
            null
        );

        Assert.isNotNull(result.result);
        Assert.areEqual(result.result, 2);
        Assert.isNull(result.error);
    }

    @IsTest
    static void validatesAValidExpressionWithAnId() {
        Account testAccount = new Account(Name = 'Test');
        QDB.getInstance().doInsert(testAccount);

        PlaygroundController.Result result = PlaygroundController.validate(
            'Name',
            testAccount.Id
        );

        Assert.isNotNull(result.result);
        Assert.areEqual(result.result, 'Test');
        Assert.isNull(result.error);
    }

    @IsTest
    static void validatesAnExpressionWithManyIdsSeparatedByComma() {
        Account testAccount1 = new Account(Name = 'Test');
        Account testAccount2 = new Account(Name = 'Test');
        QDB.getInstance().doInsert(new List<Account>{
            testAccount1, testAccount2
        });

        PlaygroundController.Result result = PlaygroundController.validate(
            'MAP(@Context, Name)',
            testAccount1.Id + ',' + testAccount2.Id
        );

        Assert.isNotNull(result.result);
        Assert.areEqual(result.result, new List<String>{
            'Test', 'Test'
        });
        Assert.isNull(result.error);
    }

    @IsTest
    static void validatesAnInvalidExpression() {
        PlaygroundController.Result result = PlaygroundController.validate(
            '1 +',
            null
        );

        Assert.isNull(result.result);
        Assert.isNotNull(result.error);
    }

    @IsTest
    static void validationsThatResultInRuntimeExceptionsContainDetailsAboutTheError() {
        PlaygroundController.Result result = PlaygroundController.validate(
            '1 + "test"',
            null
        );

        Assert.isNull(result.result);
        Assert.isNotNull(result.error);
        Assert.isNotNull(result.error.startLineNumber);
    }
}
