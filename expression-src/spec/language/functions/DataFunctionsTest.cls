@IsTest
private class DataFunctionsTest {
    private static List<Account> givenAccounts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;
        return accounts;
    }

    @IsTest
    static void canFetchAllRecordsOfAnSObject() {
        List<Account> accounts = givenAccounts();

        String expr = 'FETCH("Account", ["Id"])';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
    }

    @IsTest
    static void canQuerySpecificFieldsWhenQuerying() {
        List<Account> accounts = givenAccounts();

        String expr = 'FETCH("Account", ["Id", "Name"])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Assert.areEqual(accounts[i].Id, result[i].Id);
            Assert.areEqual(accounts[i].Name, result[i].Name);
        }
    }

    @IsTest
    static void canOrderByAField() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name"))';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        // Order by is ascending by default
        Assert.areEqual(2, result.size());
        Assert.areEqual(aAccount.Id, result[0].Id);
        Assert.areEqual(zAccount.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByAFieldAndExplicitlySpecifyAscending() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "ASC"))';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(aAccount.Id, result[0].Id);
        Assert.areEqual(zAccount.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByAFieldDescending() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "DESC"))';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(zAccount.Id, result[0].Id);
        Assert.areEqual(aAccount.Id, result[1].Id);
    }

    @IsTest
    static void usingOrderByThrowsAnExceptionWhenAnOrderThatIsNeitherAscNorDescIsSpecified() {
        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "DESCENDING"))';
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    static void usingOrderbyOutsideOfFetchThrowsAnException_topCall() {
        String expr = 'ORDERBY("Name")';
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    static void usingOrderbyOutsideOfFetchThrowsAnException_subCall() {
        String expr = 'TRANSFORM(ORDERBY("Name", "DESC"))';
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    // WHERE: One condition
    // WHERE: Multiple conditions
    // And support
    // Or support
    // Limits
    // Offset
    // Subquery
}
