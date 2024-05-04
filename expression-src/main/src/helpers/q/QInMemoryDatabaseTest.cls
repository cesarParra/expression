@IsTest
private class QInMemoryDatabaseTest {
    private static final QDB db;

    static {
        QDB.memory();
        db = QDB.getInstance();
    }

    @IsTest
    static void canGetAllRecordsForAnSObjectType() {
        // Given a database with an account record
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
        Account a = new Account(Name = 'Test Account');
        db.doInsert(a);

        // Then the account has an Id
        Assert.isNotNull(a.Id);
    }

    @IsTest
    static void canInsertMultipleRecordsAtAtime() {
        // Given a database with an account record
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

    @IsTest
    static void canOrderByAField_specifyDescending() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B');
        Account a = new Account(Name = 'Account A');
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('Name').descending());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual('Account B', results[0].get('Name'));
        Assert.areEqual('Account A', results[1].get('Name'));
    }

    @IsTest
    static void canOrderByAField_specifyNullsFirst() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B', NumberOfEmployees = 10);
        Account a = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('NumberOfEmployees').nullsFirst());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.isNull(results[0].get('NumberOfEmployees'));
        Assert.areEqual(10, results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canOrderByAField_descending_nullsFirst() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B', NumberOfEmployees = 10);
        Account a = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('NumberOfEmployees').descending().nullsFirst());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.isNull(results[0].get('NumberOfEmployees'));
        Assert.areEqual(10, results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canOrderByAField_specifyNullsLast() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B', NumberOfEmployees = 10);
        Account a = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            a, b
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('NumberOfEmployees').nullsLast());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual(10, results[0].get('NumberOfEmployees'));
        Assert.isNull(results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canOrderByAField_descending_nullsLast() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B', NumberOfEmployees = 10);
        Account a = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            a, b
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('NumberOfEmployees').descending().nullsLast());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual(10, results[0].get('NumberOfEmployees'));
        Assert.isNull(results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canOrderByMultipleFields() {
        // Given a database with multiple account records
        Account b = new Account(Name = 'Account B', NumberOfEmployees = 10);
        Account a = new Account(Name = 'Account A', NumberOfEmployees = 10);
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('NumberOfEmployees').descending())
            .add(Q.orderBy('Name'));

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual('Account A', results[0].get('Name'));
        Assert.areEqual('Account B', results[1].get('Name'));
    }

    @IsTest
    static void canOrderByMultipleFields_nullsFirst() {
        // Given a database with multiple account records
        Account a = new Account(Name = 'Account A', NumberOfEmployees = 10);
        Account b = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            a, b
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('Name'))
            .add(Q.orderBy('NumberOfEmployees').nullsFirst());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.isNull(results[0].get('NumberOfEmployees'));
        Assert.areEqual(10, results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canOrderByMultipleFields_nullsLast() {
        // Given a database with multiple account records
        Account a = new Account(Name = 'Account A', NumberOfEmployees = 10);
        Account b = new Account(Name = 'Account A', NumberOfEmployees = null);
        db.doInsert(new List<Account>{
            b, a
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orderBy('Name'))
            .add(Q.orderBy('NumberOfEmployees').nullsLast());

        // When the query is executed
        List<SObject> results = db.run(query);

        // Then the accounts are returned in order
        Assert.areEqual(10, results[0].get('NumberOfEmployees'));
        Assert.isNull(results[1].get('NumberOfEmployees'));
    }

    @IsTest
    static void canQueryUsingACondition_isNull() {
        Account accountWithBillingCountry = new Account(Name = 'Account with Billing Country', BillingCountry = 'USA');
        Account accountWithoutBillingCountry = new Account(Name = 'Account without Billing Country');
        db.doInsert(new List<Account>{
            accountWithBillingCountry, accountWithoutBillingCountry
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('BillingCountry').isNull());

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Account without Billing Country', results[0].get('Name'));
    }

//    @IsTest
//    static void canQueryUsingACondition() {
//        Account accountWithBillingCountry = new Account(Name = 'Account with Billing Country', BillingCountry = 'USA');
//        Account accountWithoutBillingCountry = new Account(Name = 'Account without Billing Country');
//        db.doInsert(new List<Account>{
//            accountWithBillingCountry, accountWithoutBillingCountry
//        });
//
//        Q query = new Q(Account.SObjectType)
//            .add(Q.condition('BillingCountry').isNotNull());
//
//        List<SObject> results = db.run(query);
//
//        Assert.areEqual(1, results.size());
//        Assert.areEqual('Account with Billing Country', results[0].get('Name'));
//    }

    // Conditions
    // is null
    // is not null
    // Equals
    // Not equals
    // less than
    // less than or equal
    // greater than
    // greater than or equal
    // is like
    // is in
    // not in
    // includes
    // excludes
}
