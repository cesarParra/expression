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

    @IsTest
    static void canInsertMultipleRecordsAtAtime() {
        // Given a database with an account record
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account a = new Account(Name = 'Test Account');
        Account b = new Account(Name = 'Test Account 2');
        db.doInsert(new List<Account>{
            a, b
        });

        // And a Q that selects all accounts
        Q query = new Q(Account.SObjectType);

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the account is returned
        Assert.areEqual(2, results.size());
    }

    @IsTest
    static void canSelectForASpecificSObjectType() {
        // Given a database with an account record
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account a = new Account(Name = 'Test Account');
        db.doInsert(a);

        // And a contact record
        Contact c = new Contact(LastName = 'Test Contact');
        db.doInsert(c);

        // And a Q that selects all accounts
        Q query = new Q(Account.SObjectType);

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the account is returned
        Assert.areEqual(1, results.size());
    }

    @IsTest
    static void canOrderByAField() {
        // Given a database with multiple account records
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account b = new Account(Name = 'Account B');
        Account a = new Account(Name = 'Account A');
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('Name'));

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual('Account A', results[0].get('Name'));
        Assert.areEqual('Account B', results[1].get('Name'));
    }

    @IsTest
    static void canOrderByAField_specifyAscending() {
        // Given a database with multiple account records
        QInMemoryDatabase db = QInMemoryDatabase.getInstance();
        Account b = new Account(Name = 'Account B');
        Account a = new Account(Name = 'Account A');
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('Name').ascending());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual('Account A', results[0].get('Name'));
        Assert.areEqual('Account B', results[1].get('Name'));
    }

    // Order by
    // single field ascending
    // single field descending
    // single field ascending nulls first
    // single field ascending nulls last
    // multiple fields
    // multiple fields with nulls first
    // multiple fields with nulls last
}
