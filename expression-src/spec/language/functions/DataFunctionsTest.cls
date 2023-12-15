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

    // TODO: Can use string literals when querying for fields.

//    @IsTest
//    static void canOrderByAFieldWhenQuerying() {
//        List<Account> accountsInDatabase = new List<Account>();
//        Account zAccount = new Account(Name = 'Z Account');
//        Account aAccount = new Account(Name = 'A Account');
//        accountsInDatabase.add(zAccount);
//        accountsInDatabase.add(aAccount);
//        insert accountsInDatabase;
//
//        String expr = 'QUERY(Account(orderBy: Name) {Id, Name})';
//        List<Account> result = (List<Account>) Evaluator.run(expr);
//
//        // Order by is ascending by default
//        Assert.areEqual(2, result.size());
//        Assert.areEqual(aAccount.Id, result[0].Id);
//        Assert.areEqual(zAccount.Id, result[1].Id);
//    }

//    @IsTest
//    static void canOrderByRelationshipField() {
//        Account account1 = new Account(Name = 'ZTest');
//        Account account2 = new Account(Name = 'ATest');
//        insert new List<Account>{
//            account1, account2
//        };
//
//        Contact zContact = new Contact(AccountId = account1.Id, LastName = 'ZTest');
//        Contact aContact = new Contact(AccountId = account2.Id, LastName = 'ATest');
//        insert new List<Contact>{
//            zContact, aContact
//        };
//
//        String expr = 'QUERY(Contact(orderBy: Account.Name) {Id, Account.Name})';
//        List<Contact> result = (List<Contact>) Evaluator.run(expr);
//
//        Assert.areEqual(2, result.size());
//        Assert.areEqual(aContact.Id, result[0].Id);
//        Assert.areEqual(zContact.Id, result[1].Id);
//    }

//    @IsTest
//    static void canOrderByAFieldAndExplicitlySpecifyAscending() {
//        List<Account> accountsInDatabase = new List<Account>();
//        Account zAccount = new Account(Name = 'Z Account');
//        Account aAccount = new Account(Name = 'A Account');
//        accountsInDatabase.add(zAccount);
//        accountsInDatabase.add(aAccount);
//        insert accountsInDatabase;
//
//        String expr = 'QUERY(Account(orderBy: [Name:ASC]) {Id, Name})';
//        List<Account> result = (List<Account>) Evaluator.run(expr);
//
//        Assert.areEqual(2, result.size());
//        Assert.areEqual(aAccount.Id, result[0].Id);
//        Assert.areEqual(zAccount.Id, result[1].Id);
//    }

    // TODO: Can order by multiple fields
    // TODO: Can order by multiple fields with specifics

//
//    @IsTest
//    static void canOrderByAFieldAndExplicitlySpecifyAscending() {
//        List<Account> accountsInDatabase = new List<Account>();
//        Account zAccount = new Account(Name = 'Z Account');
//        Account aAccount = new Account(Name = 'A Account');
//        accountsInDatabase.add(zAccount);
//        accountsInDatabase.add(aAccount);
//        insert accountsInDatabase;
//
//        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "ASC"))';
//        List<Account> result = (List<Account>) Evaluator.run(expr);
//
//        Assert.areEqual(2, result.size());
//        Assert.areEqual(aAccount.Id, result[0].Id);
//        Assert.areEqual(zAccount.Id, result[1].Id);
//    }
//
//    @IsTest
//    static void canOrderByAFieldDescending() {
//        List<Account> accountsInDatabase = new List<Account>();
//        Account zAccount = new Account(Name = 'Z Account');
//        Account aAccount = new Account(Name = 'A Account');
//        accountsInDatabase.add(zAccount);
//        accountsInDatabase.add(aAccount);
//        insert accountsInDatabase;
//
//        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "DESC"))';
//        List<Account> result = (List<Account>) Evaluator.run(expr);
//
//        Assert.areEqual(2, result.size());
//        Assert.areEqual(zAccount.Id, result[0].Id);
//        Assert.areEqual(aAccount.Id, result[1].Id);
//    }
//
//    @IsTest
//    static void usingOrderByThrowsAnExceptionWhenAnOrderThatIsNeitherAscNorDescIsSpecified() {
//        String expr = 'FETCH("Account", ["Id", "Name"], ORDERBY("Name", "DESCENDING"))';
//        try {
//            Evaluator.run(expr);
//            Assert.fail('Expected an exception to be thrown');
//        } catch (Exception e) {
//            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
//        }
//    }
//
//    @IsTest
//    static void usingOrderbyOutsideOfFetchThrowsAnException_topCall() {
//        String expr = 'ORDERBY("Name")';
//        try {
//            Evaluator.run(expr);
//            Assert.fail('Expected an exception to be thrown');
//        } catch (Exception e) {
//            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
//        }
//    }
//
//    @IsTest
//    static void usingOrderbyOutsideOfFetchThrowsAnException_subCall() {
//        String expr = 'TRANSFORM(ORDERBY("Name", "DESC"))';
//        try {
//            Evaluator.run(expr);
//            Assert.fail('Expected an exception to be thrown');
//        } catch (Exception e) {
//            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
//        }
//    }
//
//    // WHERE: One condition
//    // WHERE: Multiple conditions
//    // And support
//    // Or support
//    // Limits
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
