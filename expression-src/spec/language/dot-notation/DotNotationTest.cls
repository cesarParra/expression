@IsTest
private class DotNotationTest {
    @IsTest
    private static void dotNotationGetsRelatedData() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Name FROM Contact WHERE Id = :childContact.Id];

        Object result = Evaluator.run('Account.Name', queriedContact);

        Assert.areEqual('Parent', result);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevels() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Parent.Parent.Name FROM Contact WHERE Id = :childContact.Id];

        Object result = Evaluator.run('Account.Parent.Parent.Name', queriedContact);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevelsUsingId() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Object result = Evaluator.run('Account.Parent.Parent.Name', childContact.Id);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void canAccessMapKeysUsingDotNotation() {
        String formula = 'MAP([{"keyName": "A"}, {"keyName": "B"}], $current.keyName)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual('A', ((List<Object>) result)[0]);
        Assert.areEqual('B', ((List<Object>) result)[1]);
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToSObjectGetExpr() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('Query(Account[]) -> FIRST().Name("Test")',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToMapGetExpr() {
        try {
            Evaluator.run('{"Name": "Test"}.Name("Test")');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingFieldThatDoesNotExist() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('FETCH("Account", []) -> FIRST().NonExistentField',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingKeyThatDoesNotExist() {
        try {
            Evaluator.run('{"Name": "Test"}.NonExistentKey');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenUsingGetExpressionInAnInvalidWay() {
        try {
            Evaluator.run('$DoesNotExist.DoSomething');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }
}
