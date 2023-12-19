@IsTest
private class QueryTest {
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

    @IsTest
    static void canHaveAWhereConditionWithALikeFunction_usingPercentWildcard_throwsExceptionWhenTheFirstArgumentDoesNotEvaluateToString() {
        String expr = 'QUERY(Account(where: LIKE(1, "Test 5%")) [Id, Name])';
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    static void canHaveAWhereConditionWithALikeFunction_usingPercentWildcard() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            if (i == 5) {
                name = 'Test 5 - 6';
            }
            accountsInDatabase.add(new Account(Name = name));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: LIKE(Name, "Test 5%")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5 - 6', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereConditionWithALikeFunction_usingUnderscoreWildcard() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            if (i == 5) {
                name = 'Test 5 - 6';
            }
            accountsInDatabase.add(new Account(Name = name));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: LIKE(Name, "_est 5 - 6")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5 - 6', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereConditionWithAnIsInClause() {
        List<Account> accountsInDatabase = new List<Account>();
        Account account1 = new Account(Name = 'Test 1');
        Account account2 = new Account(Name = 'Test 2');
        Account account3 = new Account(Name = 'Test 3');
        accountsInDatabase.add(account1);
        accountsInDatabase.add(account2);
        accountsInDatabase.add(account3);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: IsIn(Id,  ["' + account1.Id + '", "' + account2.Id + '"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual(account1.Id, result[0].Id);
        Assert.areEqual(account2.Id, result[1].Id);
    }

    @IsTest
    static void canHaveAWhereConditionWithAnIsNotInClause() {
        List<Account> accountsInDatabase = new List<Account>();
        Account account1 = new Account(Name = 'Test 1');
        Account account2 = new Account(Name = 'Test 2');
        Account account3 = new Account(Name = 'Test 3');
        accountsInDatabase.add(account1);
        accountsInDatabase.add(account2);
        accountsInDatabase.add(account3);
        insert accountsInDatabase;

        String expr = 'QUERY(Account(where: IsNotIn(Id,  ["' + account1.Id + '", "' + account2.Id + '"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(account3.Id, result[0].Id);
    }

    @IsTest
    static void canUsePipesWhenUsingWhereFunctions() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: Name -> ISIN(["Test"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void canUseTheIsNullFunctionInAWhereClause() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: ISNULL(Name)) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(0, result.size());
    }

    @IsTest
    static void canUseTheIsNotNullFunctionInAWhereClause() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: ISNOTNULL(Name)) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void canSpecifyAnOffSet() {
        List<Account> accountsInDatabase = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            accountsInDatabase.add(new Account(Name = name));
        }
        insert accountsInDatabase;

        String expr = 'QUERY(Account(offset: 5, orderBy: Name) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
        Assert.areEqual('Test 5', result[0].Name);
        Assert.areEqual('Test 6', result[1].Name);
        Assert.areEqual('Test 7', result[2].Name);
        Assert.areEqual('Test 8', result[3].Name);
        Assert.areEqual('Test 9', result[4].Name);
    }

    @IsTest
    static void supportsMultipleAndConditionsThroughAmpOperator() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: Name = "Test" && Id = "' + someAccount.Id + '") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void supportsMultipleAndConditionsThroughAmpOperator_withMultipleConditions() {
        Account someAccount = new Account(Name = 'Test', NumberOfEmployees = 5, AnnualRevenue = 1000);
        insert someAccount;

        String expr = 'QUERY(Account(where: Name = "Test" && NumberOfEmployees = 5 && AnnualRevenue = 1000) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    // TODO: Mixing and matching multiple ANDs
    // TODO: Same but through the AND function
    // TODO: Or through ||
    // TODO: Or through the OR function

    // TODO: Mixing and matching multiple ORs
    // TODO: Mixing and matching ANDs and ORs
}
