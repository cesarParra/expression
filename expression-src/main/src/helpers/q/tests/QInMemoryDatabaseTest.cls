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

    @IsTest
    static void canQueryUsingACondition_isNotNull() {
        Account accountWithBillingCountry = new Account(Name = 'Account with Billing Country', BillingCountry = 'USA');
        Account accountWithoutBillingCountry = new Account(Name = 'Account without Billing Country');
        db.doInsert(new List<Account>{
            accountWithBillingCountry, accountWithoutBillingCountry
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('BillingCountry').isNotNull());

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Account with Billing Country', results[0].get('Name'));
    }

    @IsTest
    static void canQueryUsingACondition_comparingStringsThatAreEqual() {
        Account account1 = new Account(Name = 'Test Account');
        Account account2 = new Account(Name = 'Test Account 2');
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').equalsTo('Test Account'));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Test Account', results[0].get('Name'));
    }

    @IsTest
    static void canQueryUsingACondition_comparingStringsThatAreNotEqual() {
        Account account1 = new Account(Name = 'Test Account');
        Account account2 = new Account(Name = 'Test Account 2');
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').notEqualsTo('Test Account'));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Test Account 2', results[0].get('Name'));
    }

    @IsTest
    static void canQueryUsingACondition_comparingNumbersThatAreEqual() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').equalsTo(10));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(10, results[0].get('NumberOfEmployees'));
    }

    @IsTest
    static void canQueryUsingACondition_comparingNumbersThatAreNotEqual() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').notEqualsTo(10));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(20, results[0].get('NumberOfEmployees'));
    }

    @IsTest
    static void canQueryUsingACondition_comparingDatesThatAreEqual() {
        Date date1 = Date.newInstance(2020, 1, 1);
        Date date2 = Date.newInstance(2020, 1, 2);

        Contact contact1 = new Contact(FirstName = 'Person 1', Birthdate = date1);
        Contact contact2 = new Contact(FirstName = 'Person 2', Birthdate = date2);
        db.doInsert(new List<Contact>{
            contact1, contact2
        });

        Q query = new Q(Contact.SObjectType)
            .add(Q.condition('Birthdate').equalsTo(date1));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(contact1, results[0]);
    }

    @IsTest
    static void canQueryUsingACondition_comparingDatesThatAreNotEqual() {
        Date date1 = Date.newInstance(2020, 1, 1);
        Date date2 = Date.newInstance(2020, 1, 2);

        Contact contact1 = new Contact(FirstName = 'Person 1', Birthdate = date1);
        Contact contact2 = new Contact(FirstName = 'Person 2', Birthdate = date2);
        db.doInsert(new List<Contact>{
            contact1, contact2
        });

        Q query = new Q(Contact.SObjectType)
            .add(Q.condition('Birthdate').notEqualsTo(date1));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(contact2, results[0]);
    }

    @IsTest
    static void canQueryUsingACondition_dateTimesThatAreEqual() {
        Datetime dateTime1 = Datetime.newInstance(2020, 1, 1, 1, 1, 1);
        Datetime dateTime2 = Datetime.newInstance(2020, 1, 1, 1, 1, 2);

        Asset asset1 = new Asset(UptimeRecordStart = dateTime1);
        Asset asset2 = new Asset(UptimeRecordStart = dateTime2);
        db.doInsert(new List<Asset>{
            asset1, asset2
        });

        Q query = new Q(Asset.SObjectType)
            .add(Q.condition('UptimeRecordStart').equalsTo(dateTime1));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(asset1, results[0]);
    }

    @IsTest
    static void canQueryUsingACondition_dateTimesThatAreNotEqual() {
        Datetime dateTime1 = Datetime.newInstance(2020, 1, 1, 1, 1, 1);
        Datetime dateTime2 = Datetime.newInstance(2020, 1, 1, 1, 1, 2);

        Asset asset1 = new Asset(UptimeRecordStart = dateTime1);
        Asset asset2 = new Asset(UptimeRecordStart = dateTime2);
        db.doInsert(new List<Asset>{
            asset1, asset2
        });

        Q query = new Q(Asset.SObjectType)
            .add(Q.condition('UptimeRecordStart').notEqualsTo(dateTime1));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(asset2, results[0]);
    }

    @IsTest
    static void canQueryUsingACondition_lessThan() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').isLessThan(20));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(10, results[0].get('NumberOfEmployees'));
    }

    @IsTest
    static void canQueryUsingACondition_lessThanOrEqualTo() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        Account account3 = new Account(Name = 'Test Account 3', NumberOfEmployees = 30);
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').isLessOrEquals(20));

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
        Assert.isTrue(results.contains(account1));
        Assert.isTrue(results.contains(account2));
    }

    @IsTest
    static void canQueryUsingACondition_greaterThan() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').isGreaterThan(10));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual(20, results[0].get('NumberOfEmployees'));
    }

    @IsTest
    static void canQueryUsingACondition_greaterThanOrEqualTo() {
        Account account1 = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        Account account3 = new Account(Name = 'Test Account 3', NumberOfEmployees = 30);
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('NumberOfEmployees').isGreaterOrEquals(20));

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
        Assert.isTrue(results.contains(account2));
        Assert.isTrue(results.contains(account3));
    }

    @IsTest
    static void canQueryUsingACondition_isLike_percentWildcard() {
        Account account1 = new Account(Name = 'Someone');
        Account account2 = new Account(Name = 'Someone Else');
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').isLike('%Else'));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Someone Else', results[0].get('Name'));
    }

    @IsTest
    static void canQueryUsingACondition_isLike_underscoreWildcard() {
        Account account1 = new Account(Name = 'Someone');
        Account account2 = new Account(Name = 'Someone Else');
        db.doInsert(new List<Account>{
            account1, account2
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').isLike('Someone _lse'));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.areEqual('Someone Else', results[0].get('Name'));
    }

    @IsTest
    static void canQueryUsingACondition_isIn() {
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');
        Account account3 = new Account(Name = 'Test Account 3');
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').isIn(new List<String>{
                'Test Account 1', 'Test Account 3'
            }));

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
        Assert.isTrue(results.contains(account1));
        Assert.isTrue(results.contains(account3));
    }

    @IsTest
    static void canQueryUsingACondition_isNotIn() {
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');
        Account account3 = new Account(Name = 'Test Account 3');
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.condition('Name').isNotIn(new List<String>{
                'Test Account 1', 'Test Account 3'
            }));

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.isTrue(results.contains(account2));
    }

    @IsTest
    static void canAddALimit() {
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');
        Account account3 = new Account(Name = 'Test Account 3');
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .addLimit(2);

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
    }

    @IsTest
    static void canAddOffset() {
        Account account1 = new Account(Name = 'Test Account 1');
        Account account2 = new Account(Name = 'Test Account 2');
        Account account3 = new Account(Name = 'Test Account 3');
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .addOffset(1);

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
        Assert.isTrue(results.contains(account2));
        Assert.isTrue(results.contains(account3));
    }

    @IsTest
    static void canAddOrGroup() {
        Account account1 = new Account(Name = 'Test Account 1', NumberOfEmployees = 10);
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20);
        Account account3 = new Account(Name = 'Test Account 3', NumberOfEmployees = 30);
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.orGroup()
                .add(Q.condition('NumberOfEmployees').isLessThan(20))
                .add(Q.condition('NumberOfEmployees').isGreaterThan(20))
            );

        List<SObject> results = db.run(query);

        Assert.areEqual(2, results.size());
        Assert.isTrue(results.contains(account1));
        Assert.isTrue(results.contains(account3));
    }

    @IsTest
    static void canAddAndGroup() {
        Account account1 = new Account(Name = 'Test Account 1', NumberOfEmployees = 10, BillingCountry = 'USA');
        Account account2 = new Account(Name = 'Test Account 2', NumberOfEmployees = 20, BillingCountry = 'USA');
        Account account3 = new Account(Name = 'Test Account 3', NumberOfEmployees = 30, BillingCountry = 'Canada');
        db.doInsert(new List<Account>{
            account1, account2, account3
        });

        Q query = new Q(Account.SObjectType)
            .add(Q.andGroup()
                .add(Q.condition('NumberOfEmployees').isLessThan(20))
                .add(Q.condition('BillingCountry').equalsTo('USA'))
            );

        List<SObject> results = db.run(query);

        Assert.areEqual(1, results.size());
        Assert.isTrue(results.contains(account1));
    }

    @IsTest
    static void canAddChildrenToDatabase() {
        Account parentAccount = new Account(Name = 'Parent');
        db.doInsert(parentAccount);

        Account childAccount = new Account(Name = 'Child', ParentId = parentAccount.Id);
        db.doInsert(childAccount);

        Q queryWithSub = new Q(Account.SObjectType)
            .addSubquery(new Q('ChildAccounts'));

        List<Account> results = db.run(queryWithSub);

        Assert.areEqual(2, results.size());

        Map<Id, Account> accountsById = new Map<Id, Account>(results);
        Account requeriedParent = accountsById.get(parentAccount.Id);
        Assert.areEqual(1, requeriedParent.ChildAccounts.size());
    }

    // TODO: Also adds parent relationships to the __r or the parent SOBject
}
