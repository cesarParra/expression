@IsTest
private class DotNotationTest {
    @IsTest
    private static void dotNotationGetsRelatedData() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Name FROM Contact WHERE Id = :childContact.Id];

        Evaluator.run('Account.Name', queriedContact);
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
}
