@IsTest
private class StringInterpolationTest {
    @IsTest
    static void evaluatesAnInterpolationByItself() {
        String expression = '"${"World"}"';
        Object result = Evaluator.run(expression);
        Assert.areEqual('World', result);
    }

    @IsTest
    static void evaluatesInterpolationWithAString() {
        String expression = '"Hello ${"World"}"';
        Object result = Evaluator.run(expression);
        Assert.areEqual('Hello World', result);
    }

    @IsTest
    static void evaluatesMultipleInterpolations() {
        String expression = '"Hello ${"World"}${"!"}"';
        Object result = Evaluator.run(expression);
        Assert.areEqual('Hello World!', result);
    }

    @IsTest
    static void canReferenceSObjectFieldsInsideInterpolations() {
        Account anyRecord = new Account(Name = 'John');
        QDB.getInstance().doInsert(anyRecord);

        String expression = '"Hello ${Name}"';
        Object result = Evaluator.run(expression, anyRecord.Id);
        Assert.areEqual('Hello John', result);
    }

    @IsTest
    static void canReferenceGlobalVariables() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        User anyUser = new User(Alias = 'standard', Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', FirstName = 'Bob', LastName = 'Smith',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName);

        System.runAs(anyUser) {
            String expression = '"Hello ${$User.FirstName}"';
            Object result = Evaluator.run(expression);
            Assert.areEqual('Hello Bob', result);
        }
    }

    @IsTest
    static void canReferenceVariablesCreatedThroughLet() {
        String expression = 'LET({"$myVar": "World"}, "Hello ${$myVar}")';
        Object result = Evaluator.run(expression);
        Assert.areEqual('Hello World', result);
    }

    @IsTest
    static void canCreateInterpolationsInsideOfInterpolations() {
        String expression = '"Number: ${"${"1"}"}"';
        Object result = Evaluator.run(expression);
        Assert.areEqual('Number: 1', result);
    }

    @IsTest
    static void nonStringsReturnedByInterpolationsAreConvertedToStrings() {
        String expression = '"${1}"';
        Object result = Evaluator.run(expression);
        Assert.areEqual('1', result);
    }
}
