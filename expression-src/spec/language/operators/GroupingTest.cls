@IsTest
private class GroupingTest {
    @IsTest
    static void supportsEmptyGroups() {
        Assert.areEqual(1, Evaluator.run('((1))'));
    }

    @IsTest
    static void supportsNestedGroups() {
        Assert.areEqual(1, Evaluator.run('(((1)))'));
    }

    @IsTest
    static void supportsMultipleGroups() {
        Assert.areEqual(2, Evaluator.run('((1) + (1))'));
    }

    @IsTest
    static void supportsMultipleNestedGroups() {
        Assert.areEqual(2, Evaluator.run('(((1) + (1)))'));
    }

    @IsTest
    static void supportsExpressionsInsideOfGroups() {
        Assert.areEqual(2, Evaluator.run('(1 + 1)'));
    }
}
