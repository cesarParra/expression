@IsTest
private class BulkTest {
    @IsTest
    static void canEvaluateExpressionsInBulk() {
        List<String> expressions = new List<String> {
            '1 + 1',
            '2 * 3',
            '4 - 2',
            '5 / 5'
        };

        List<Result> results = Evaluator.run(expressions);

        Assert.areEqual(4, results.size());
        Assert.areEqual(2, results[0].getValue());
        Assert.areEqual(6, results[1].getValue());
        Assert.areEqual(2, results[2].getValue());
        Assert.areEqual(1, results[3].getValue());
    }

    @IsTest
    static void canEvaluateExpressionsInBulkUsingAnIdContext() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        List<String> expressions = new List<String> {
            'Name',
            'Name = "Test"',
            '4 - 2',
            'Id'
        };

        List<Result> results = Evaluator.run(expressions, accountRecord.Id);

        Assert.areEqual(4, results.size());
        Assert.areEqual('Test', results[0].getValue());
        Assert.isTrue((Boolean)results[1].getValue());
        Assert.areEqual(2, results[2].getValue());
        Assert.areEqual(accountRecord.Id, results[3].getValue());

        Assert.areEqual(1, Limits.getDmlStatements());
    }

    @IsTest
    static void everythingFailsIfAnyEvaluationResultsInAnError() {
        List<String> expressions = new List<String> {
            '1 + 1',
            '2 * 3',
            '4 - 2',
            '5 / 0' // This will cause a division by zero error
        };

        try {
            Evaluator.run(expressions);
            Assert.fail('Expected an exception due to division by zero');
        } catch (Exception e) {
            Assert.isTrue(true, 'Exception was thrown as expected');
        }
    }
}
