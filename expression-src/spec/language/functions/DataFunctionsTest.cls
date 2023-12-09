@IsTest
private class DataFunctionsTest {
    @IsTest
    static void canFetchAllRecordsOfAnSObject() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;

        String expr = 'FETCH("Account", ["Id"])';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);
        Assert.areEqual(accounts.size(), result.size());
    }
}
