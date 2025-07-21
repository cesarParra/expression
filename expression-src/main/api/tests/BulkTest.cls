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

    // TODO: Error handling
    // TODO: Context sharing (single DML)
}
