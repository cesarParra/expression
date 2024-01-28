@IsTest
private class CommentsTest {
    @IsTest
    private static void commentsAreIgnored() {
        Assert.areEqual(1, Evaluator.run('1 # comment'));
    }
}
