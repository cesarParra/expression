@IsTest
private class EvaluatorNullRecordIdTest {
    @IsTest
    static void evaluatesAFormulaWithNoMergeFieldsWhenTheRecordIdIsNull() {
        Object result = Evaluator.run('1 + 1', (Id)null);

        Assert.areEqual(2, result);
    }

    @IsTest
    static void evaluatesInBulkWhenTheRecordIdIsNull() {
        List<Result> results = Evaluator.run(new List<String> { '1 + 1', '"a" & "b"' }, (Id)null);

        Assert.areEqual(2, results.size());
        Assert.areEqual(2, results[0].getValue());
        Assert.areEqual('ab', results[1].getValue());
    }

    @IsTest
    static void evaluatesWithAConfigurationWhenTheRecordIdIsNull() {
        Object result = Evaluator.run('1 + 1', (Id)null, new Configuration());

        Assert.areEqual(2, result);
    }

    @IsTest
    static void queriesNothingWhenTheRecordIdIsNull() {
        Integer queriesBefore = Limits.getQueries();

        Evaluator.run('1 + 1', (Id)null);

        Assert.areEqual(queriesBefore, Limits.getQueries(), 'There is no record to query for');
    }

    @IsTest
    static void readsTheSameAsEvaluatingWithNoContextAtAll() {
        Assert.areEqual(Evaluator.run('1 + 1'), Evaluator.run('1 + 1', (Id)null));
    }

    @IsTest
    static void leavesTheContextVariablesEmptyWhenTheRecordIdIsNull() {
        Assert.isNull(Evaluator.run('@Id', (Id)null));
        Assert.isNull(Evaluator.run('@Context', (Id)null));
    }

    /**
     * A merge field has nothing to resolve against, which is a different answer from the record
     * having no value for it - so it fails rather than reading as empty. It has to fail the way
     * evaluating without a context does, though: a NullPointerException here is the defect this
     * class exists for, wearing the right outcome.
     */
    @IsTest
    static void refusesAMergeFieldWhenThereIsNoRecordToResolveItAgainst() {
        try {
            Evaluator.run('Name', (Id)null);
            Assert.fail('Expected a merge field with no context to be refused');
        } catch (Exception e) {
            Assert.isFalse(e instanceof NullPointerException,
                'Expected the same refusal as evaluating without a context, got: ' + e);
        }
    }
}
