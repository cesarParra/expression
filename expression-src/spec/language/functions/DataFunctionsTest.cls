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
}
