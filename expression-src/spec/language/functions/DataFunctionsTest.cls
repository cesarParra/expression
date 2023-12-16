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
    static void canQueryAllRecordsOfAnSObject() {
        List<Account> accounts = givenAccounts();

        String expr = 'QUERY(Account)';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
    }

    @IsTest
    static void canQueryWithAnEmptySetOfNamedParameters() {
        List<Account> accounts = givenAccounts();

        String expr = 'QUERY(Account())';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
    }

    @IsTest
    static void canGetSpecificFieldsWhenQuerying_usingMergeFields() {
        List<Account> accounts = givenAccounts();

        String expr = 'QUERY(Account[Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Assert.areEqual(accounts[i].Id, result[i].Id);
            Assert.areEqual(accounts[i].Name, result[i].Name);
        }
    }

    @IsTest
    static void canGetSpecificFieldsWhenQuerying_usingStrings() {
        List<Account> accounts = givenAccounts();

        String expr = 'QUERY(Account["Id", "Name"])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Assert.areEqual(accounts[i].Id, result[i].Id);
            Assert.areEqual(accounts[i].Name, result[i].Name);
        }
    }

    @IsTest
    static void canQueryForRelationshipFields() {
        Account account = new Account(Name = 'Test');
        insert account;

        Contact contact = new Contact(AccountId = account.Id, LastName = 'Test');
        insert contact;

        String expr = 'QUERY(Contact [Id, Account.Name])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(account.Name, result[0].Account.Name);
    }

    @IsTest
    static void canOrderByASingleFieldWhenQuerying() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(OrderBy: Name) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        // Order by is ascending by default
        Assert.areEqual(2, result.size());
        Assert.areEqual(aAccount.Id, result[0].Id);
        Assert.areEqual(zAccount.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByRelationshipField() {
        Account account1 = new Account(Name = 'ZTest');
        Account account2 = new Account(Name = 'ATest');
        insert new List<Account>{
            account1, account2
        };

        Contact zContact = new Contact(AccountId = account1.Id, LastName = 'ZTest');
        Contact aContact = new Contact(AccountId = account2.Id, LastName = 'ATest');
        insert new List<Contact>{
            zContact, aContact
        };

        String expr = 'QUERY(Contact(orderBy: Account.Name) [Id, Account.Name])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(aContact.Id, result[0].Id);
        Assert.areEqual(zContact.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByAFieldAndExplicitlySpecifyAscending() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(orderBy: Name ASC) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(aAccount.Id, result[0].Id);
        Assert.areEqual(zAccount.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByAFieldAndExplicitlySpecifyDescending() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account');
        Account aAccount = new Account(Name = 'A Account');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(orderBy: Name DESC) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(zAccount.Id, result[0].Id);
        Assert.areEqual(aAccount.Id, result[1].Id);
    }

    @IsTest
    static void canOrderByMultipleFields() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account', BillingCity = 'Z City');
        Account aAccount = new Account(Name = 'A Account', BillingCity = 'A City');
        Account aAccount2 = new Account(Name = 'A Account', BillingCity = 'Z City');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        accountsInDatabase.add(aAccount2);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(orderBy: [Name, BillingCity]) [Id, Name, BillingCity])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(3, result.size());
        Assert.areEqual(aAccount.Id, result[0].Id);
        Assert.areEqual(aAccount2.Id, result[1].Id);
        Assert.areEqual(zAccount.Id, result[2].Id);
    }

    @IsTest
    static void canOrderByMultipleFields_withDirection() {
        List<Account> accountsInDatabase = new List<Account>();
        Account zAccount = new Account(Name = 'Z Account', BillingCity = 'Z City');
        Account aAccount = new Account(Name = 'A Account', BillingCity = 'A City');
        Account aAccount2 = new Account(Name = 'A Account', BillingCity = 'Z City');
        accountsInDatabase.add(zAccount);
        accountsInDatabase.add(aAccount);
        accountsInDatabase.add(aAccount2);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(orderBy: [Name ASC, BillingCity DESC]) [Id, Name, BillingCity])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(3, result.size());
        Assert.areEqual(aAccount2.Id, result[0].Id);
        Assert.areEqual(aAccount.Id, result[1].Id);
        Assert.areEqual(zAccount.Id, result[2].Id);
    }

    @IsTest
    static void usingOrderByThrowsAnExceptionWhenAnOrderThatIsNeitherAscNorDescIsSpecified() {
        String expr = 'QUERY(Account(orderBy: Name ASCENDING) [Id, Name])';
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.ParsingException.class);
        }
    }

    @IsTest
    static void canLimitTheNumberOfRecordsReturned() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(limit: 5) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
    }

    @IsTest
    static void canHaveBothAnOrderByAndALimit() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(orderBy: Name DESC, limit: 5) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
        Assert.areEqual('Test 9', result[0].Name);
        Assert.areEqual('Test 8', result[1].Name);
        Assert.areEqual('Test 7', result[2].Name);
        Assert.areEqual('Test 6', result[3].Name);
        Assert.areEqual('Test 5', result[4].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_singleEquals() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: Name = "Test 5") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_doubleEquals() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: Name == "Test 5") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_greaterThan() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees > 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(4, result.size());
        Assert.areEqual('Test 6', result[0].Name);
        Assert.areEqual('Test 7', result[1].Name);
        Assert.areEqual('Test 8', result[2].Name);
        Assert.areEqual('Test 9', result[3].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_greaterThanOrEqual() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees >= 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
        Assert.areEqual('Test 5', result[0].Name);
        Assert.areEqual('Test 6', result[1].Name);
        Assert.areEqual('Test 7', result[2].Name);
        Assert.areEqual('Test 8', result[3].Name);
        Assert.areEqual('Test 9', result[4].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_lessThan() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees < 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
        Assert.areEqual('Test 0', result[0].Name);
        Assert.areEqual('Test 1', result[1].Name);
        Assert.areEqual('Test 2', result[2].Name);
        Assert.areEqual('Test 3', result[3].Name);
        Assert.areEqual('Test 4', result[4].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_lessThanOrEquals() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees <= 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(6, result.size());
        Assert.areEqual('Test 0', result[0].Name);
        Assert.areEqual('Test 1', result[1].Name);
        Assert.areEqual('Test 2', result[2].Name);
        Assert.areEqual('Test 3', result[3].Name);
        Assert.areEqual('Test 4', result[4].Name);
        Assert.areEqual('Test 5', result[5].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_notEquals_bangEquals() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees != 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(9, result.size());
        Assert.areEqual('Test 0', result[0].Name);
        Assert.areEqual('Test 1', result[1].Name);
        Assert.areEqual('Test 2', result[2].Name);
        Assert.areEqual('Test 3', result[3].Name);
        Assert.areEqual('Test 4', result[4].Name);
        Assert.areEqual('Test 6', result[5].Name);
        Assert.areEqual('Test 7', result[6].Name);
        Assert.areEqual('Test 8', result[7].Name);
        Assert.areEqual('Test 9', result[8].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_notEquals_lessGreater() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accountsInDatabase.add(new Account(Name = 'Test ' + i, NumberOfEmployees = i));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: NumberOfEmployees <> 5) [Id, Name, NumberOfEmployees])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(9, result.size());
        Assert.areEqual('Test 0', result[0].Name);
        Assert.areEqual('Test 1', result[1].Name);
        Assert.areEqual('Test 2', result[2].Name);
        Assert.areEqual('Test 3', result[3].Name);
        Assert.areEqual('Test 4', result[4].Name);
        Assert.areEqual('Test 6', result[5].Name);
        Assert.areEqual('Test 7', result[6].Name);
        Assert.areEqual('Test 8', result[7].Name);
        Assert.areEqual('Test 9', result[8].Name);
    }

//    // WHERE: Multiple conditions
//    // And support
//    // Or support
//    // Offset
//    // Subquery

    // Combining query contexts with top level context (Id based).
    // so that for example we can do a dynamic query based on data of the
    // context record -> we can do this by wrapping everything in LET and
    // using variables

    // Can use pipes for the named parameter expressions

    // Update the example project
    // Update docs
    // Deprecate FETCH
}
