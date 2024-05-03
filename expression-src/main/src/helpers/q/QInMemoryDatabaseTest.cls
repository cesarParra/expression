@IsTest
private class QInMemoryDatabaseTest {
    @IsTest
    static void canGetAllRecordsForAnSObjectType() {
        // Given a database with an account record
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account a = new Account(Name = 'Test Account');
        db.doInsert(a);

        // And a Q that selects all accounts
        Q query = new Q(Account.SObjectType);

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the account is returned
        Assert.areEqual(1, results.size());
        Account result = (Account) results[0];
    }

    @IsTest
    static void setsAnIdToTheRecordWhenInsertingIt() {
        // Given a database with an account record
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account a = new Account(Name = 'Test Account');
        db.doInsert(a);

        // Then the account has an Id
        Assert.isNotNull(a.Id);
    }

    // can insert multiple records at a time
    // can select for a specific SObjecttype when there is more than one SObject type in the db
}
