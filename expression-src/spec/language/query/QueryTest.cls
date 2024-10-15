@IsTest
private class QueryTest {
    private class FluentDataBuilder {
        private final List<SObject> registeredRecords = new List<SObject>();

        public SObject first { get {return registeredRecords[0];} }

        public List<SObject> all { get {return registeredRecords;} }

        private FluentDataBuilder andGivenAn(ITestDataBuilder builder) {
            registeredRecords.add(builder.registerNewForInsert());
            return this;
        }

        private FluentDataBuilder inTheDatabase() {
            SObjectTestDataBuilder.commitRecords();
            return this;
        }
    }

    private static FluentDataBuilder given() {
        return new FluentDataBuilder();
    }

    private static FluentDataBuilder givenAn(ITestDataBuilder builder) {
        return new FluentDataBuilder().andGivenAn(builder);
    }

    private static List<Account> given10Accounts() {
        List<Account> accounts = (List<Account>) SObjectTestDataBuilder.of(Account.SObjectType)
            .registerNewForInsert(10);
        SObjectTestDataBuilder.commitRecords();
        return accounts;
    }

    private static void runAndAssertRuntimeException(String expr) {
        try {
            Evaluator.run(expr);
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    static void canQueryAllRecordsOfAnSObject() {
        given10Accounts();

        String expr = 'QUERY(Account)';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);

        Assert.areEqual(10, result.size());
    }

    @IsTest
    static void canQueryWithAnEmptySetOfNamedParameters() {
        given10Accounts();

        String expr = 'QUERY(Account())';
        List<SObject> result = (List<SObject>) Evaluator.run(expr);

        Assert.areEqual(10, result.size());
    }

    @IsTest
    static void canGetSpecificFieldsWhenQuerying_usingMergeFields() {
        List<Account> accounts = given10Accounts();

        String expr = 'QUERY(Account[Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Assert.areEqual(accounts[i].Id, result[i].Id);
            Assert.areEqual(accounts[i].Name, result[i].Name);
        }
    }

    @IsTest
    static void throwsAnExceptionIfTheFieldsSectionDoesNotEvaluateToAList() {
        String expr = 'Query(Account{})';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canGetSpecificFieldsWhenQuerying_usingStrings() {
        List<Account> accounts = given10Accounts();

        String expr = 'QUERY(Account["Id", "Name"])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(accounts.size(), result.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Assert.areEqual(accounts[i].Id, result[i].Id);
            Assert.areEqual(accounts[i].Name, result[i].Name);
        }
    }

    @IsTest
    static void throwsAnExceptionIfAnyOfTheFieldsBeingQueriedDoNotEvaluateToAStringOrAMergeField() {
        String expr = 'Query(Account[Id, 1])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canQueryForRelationshipFields() {
        Account account = (Account) givenAn(AccountTestRecord.any().withAChildContact()).inTheDatabase().first;

        String expr = 'QUERY(Contact [Id, Account.Name])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(account.Name, result[0].Account.Name);
    }

    @IsTest
    static void canOrderByASingleFieldWhenQuerying() {
        givenAn(AccountTestRecord.build().named('Z Account'))
            .andGivenAn(AccountTestRecord.build().named('A Account'))
            .inTheDatabase();

        String expr = 'QUERY(Account(OrderBy: Name) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        // Order by is ascending by default
        Assert.areEqual(2, result.size());
        Assert.areEqual('A Account', result[0].Name);
        Assert.areEqual('Z Account', result[1].Name);
    }

    @IsTest
    static void canOrderByRelationshipField() {
        givenAn(AccountTestRecord.any().withAChildContact(ContactTestRecord.build()).named('ZTest'))
            .andGivenAn(AccountTestRecord.any().withAChildContact(ContactTestRecord.build()).named('ATest'))
            .inTheDatabase();

        String expr = 'QUERY(Contact(orderBy: Account.Name) [Id, Account.Name])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual('ATest', result[0].Account.Name);
        Assert.areEqual('ZTest', result[1].Account.Name);
    }

    @IsTest
    static void canOrderByAFieldAndExplicitlySpecifyAscending() {
        givenAn(AccountTestRecord.build().named('Z Account'))
            .andGivenAn(AccountTestRecord.build().named('A Account'))
            .inTheDatabase();

        String expr = 'QUERY(Account(orderBy: Name ASC) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual('A Account', result[0].Name);
        Assert.areEqual('Z Account', result[1].Name);
    }

    @IsTest
    static void canOrderByAFieldAndExplicitlySpecifyDescending() {
        givenAn(AccountTestRecord.build().named('Z Account'))
            .andGivenAn(AccountTestRecord.build().named('A Account'))
            .inTheDatabase();

        String expr = 'QUERY(Account(orderBy: Name DESC) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual('Z Account', result[0].Name);
        Assert.areEqual('A Account', result[1].Name);
    }

    @IsTest
    static void canOrderByMultipleFields() {
        List<Account> accountsInDatabase = (List<Account>) givenAn(
            AccountTestRecord.build().named('Z Account').withBillingCity('Z City')
        ).andGivenAn(
            AccountTestRecord.build().named('A Account').withBillingCity('A City')
        ).andGivenAn(
            AccountTestRecord.build().named('A Account').withBillingCity('Z City')
        ).inTheDatabase().all;

        String expr = 'QUERY(Account(orderBy: [Name, BillingCity]) [Id, Name, BillingCity])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(3, result.size());
        Assert.areEqual(accountsInDatabase[1].Id, result[0].Id);
        Assert.areEqual(accountsInDatabase[2].Id, result[1].Id);
        Assert.areEqual(accountsInDatabase[0].Id, result[2].Id);
    }

    @IsTest
    static void canOrderByMultipleFields_withDirection() {
        List<Account> accountsInDatabase = (List<Account>) givenAn(
            AccountTestRecord.build().named('Z Account').withBillingCity('Z City')
        ).andGivenAn(
            AccountTestRecord.build().named('A Account').withBillingCity('A City')
        ).andGivenAn(
            AccountTestRecord.build().named('A Account').withBillingCity('Z City')
        ).inTheDatabase().all;

        String expr = 'QUERY(Account(orderBy: [Name ASC, BillingCity DESC]) [Id, Name, BillingCity])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(3, result.size());
        Assert.areEqual(accountsInDatabase[2].Id, result[0].Id);
        Assert.areEqual(accountsInDatabase[1].Id, result[1].Id);
        Assert.areEqual(accountsInDatabase[0].Id, result[2].Id);
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
    static void usingOrderByThrowsAnExceptionIfTheFieldDoesNotEvaluateToAString() {
        String expr = 'QUERY(Account(orderBy: 1) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canLimitTheNumberOfRecordsReturned() {
        given10Accounts();

        String expr = 'QUERY(Account(limit: 5) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(5, result.size());
    }

    @IsTest
    static void usingLimitThrowsAnExceptionIfTheLimitDoesNotEvaluateToAnInteger() {
        String expr = 'QUERY(Account(limit: "1") [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canHaveBothAnOrderByAndALimit() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i));
        }
        dataBuilder.inTheDatabase();

        String expr = 'QUERY(Account(where: Name = "Test 5") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5', result[0].Name);
    }

    @IsTest
    static void usingTheWhereConditionThrowsAnExceptionIfTheFirstArgumentDoesNotEvaluateToACondition() {
        String expr = 'QUERY(Account(where: 1) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canHaveAWhereCondition_doubleEquals() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i));
        }
        dataBuilder.inTheDatabase();

        String expr = 'QUERY(Account(where: Name == "Test 5") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereCondition_greaterThan() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            dataBuilder.andGivenAn(AccountTestRecord.build().named('Test ' + i).withNumberOfEmployees(i));
        }
        dataBuilder.inTheDatabase();

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
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void throwsAnExceptionWhenTheSecondArgumentOfLikeDoesNotEvaluateToString() {
        String expr = 'QUERY(Account(where: LIKE(Name, 1)) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canHaveAWhereConditionWithALikeFunction_usingPercentWildcard() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            if (i == 5) {
                name = 'Test 5 - 6';
            }
            dataBuilder.andGivenAn(AccountTestRecord.build().named(name));
        }
        dataBuilder.inTheDatabase();

        String expr = 'QUERY(Account(where: LIKE(Name, "Test 5%")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5 - 6', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereConditionWithALikeFunction_usingUnderscoreWildcard() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            if (i == 5) {
                name = 'Test 5 - 6';
            }
            dataBuilder.andGivenAn(AccountTestRecord.build().named(name));
        }
        dataBuilder.inTheDatabase();

        String expr = 'QUERY(Account(where: LIKE(Name, "_est 5 - 6")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 5 - 6', result[0].Name);
    }

    @IsTest
    static void canHaveAWhereConditionWithAnIsInClause() {
        List<Account> accountsInDatabase = (List<Account>) givenAn(
            AccountTestRecord.build().named('Test 1')
        ).andGivenAn(
            AccountTestRecord.build().named('Test 2')
        ).andGivenAn(
            AccountTestRecord.build().named('Test 3')
        ).inTheDatabase().all;

        String expr = 'QUERY(Account(where: IsIn(Id,  ["' + accountsInDatabase[0].Id + '", "' + accountsInDatabase[1].Id + '"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Assert.areEqual('Test 1', result[0].Name);
        Assert.areEqual('Test 2', result[1].Name);
    }

    @IsTest
    static void throwsAnExceptionWhenTheFirstArgumentOfIsInDoesNotEvaluateToAString() {
        String expr = 'QUERY(Account(where: IsIn(1,  ["Test 1", "Test 2"])) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void throwsAnExceptionWhenTheSecondArgumentOfIsInDoesNotEvaluateToAList() {
        String expr = 'QUERY(Account(where: IsIn(Name,  1)) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void throwsAnExceptionWhenTheSecondArgumentOfIsInIsEmpty() {
        String expr = 'QUERY(Account(where: IsIn(Name,  [])) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canHaveAWhereConditionWithAnIsNotInClause() {
        List<Account> accountsInDatabase = (List<Account>) givenAn(
            AccountTestRecord.build().named('Test 1')
        ).andGivenAn(
            AccountTestRecord.build().named('Test 2')
        ).andGivenAn(
            AccountTestRecord.build().named('Test 3')
        ).inTheDatabase().all;

        String expr = 'QUERY(Account(where: IsNotIn(Id,  ["' + accountsInDatabase[0].Id + '", "' + accountsInDatabase[1].Id + '"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test 3', result[0].Name);
    }

    @IsTest
    static void isNotInThrowsAnExceptionWhenTheFirstArgumentDoesNotEvaluateToAString() {
        String expr = 'QUERY(Account(where: IsNotIn(1,  ["Test 1", "Test 2"])) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void isNotInThrowsAnExceptionWhenTheSecondArgumentDoesNotEvaluateToAList() {
        String expr = 'QUERY(Account(where: IsNotIn(Name,  1)) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void isNotInThrowsAnExceptionWhenTheSecondArgumentIsEmpty() {
        String expr = 'QUERY(Account(where: IsNotIn(Name,  [])) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canUsePipesWhenUsingWhereFunctions() {
        givenAn(AccountTestRecord.build().named('Test'))
            .inTheDatabase();

        String expr = 'QUERY(Account(where: Name -> ISIN(["Test"])) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test', result[0].Name);
    }

    @IsTest
    static void canUseTheIsNullFunctionInAWhereClause() {
        givenAn(AccountTestRecord.build().named('Test'))
            .inTheDatabase();

        String expr = 'QUERY(Account(where: ISNULL(Name)) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(0, result.size());
    }

    @IsTest
    static void usingIsNullThrowsAnExceptionWhenTheArgumentDoesNotEvaluateToAString() {
        String expr = 'QUERY(Account(where: ISNULL(1)) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canUseTheIsNotNullFunctionInAWhereClause() {
        givenAn(AccountTestRecord.build().named('Test'))
            .inTheDatabase();

        String expr = 'QUERY(Account(where: ISNOTNULL(Name)) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void usingIsNotNullThrowsAnExceptionWhenTheArgumentDoesNotEvaluateToAString() {
        String expr = 'QUERY(Account(where: ISNOTNULL(1)) [Id, Name])';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void canHaveAWhereConditionWithAGetExpressionToAVariable() {
        FluentDataBuilder builder = givenAn(AccountTestRecord.build().named('Test'))
            .inTheDatabase();
        Id recordId = builder.first.Id;

        String expr = 'QUERY(Account(where: Id = @ContextAcc.Id) [Id, Name])';
        Configuration config = new Configuration().withCustomContext(
            new Map<String, Object>{
                'ContextAcc' => new Map<String, Object>{
                    'Id' => recordId
                }
            }
        );
        List<Account> result = (List<Account>) Evaluator.run(expr, config);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test', result[0].Name);
    }

    @IsTest
    static void canSpecifyAnOffSet() {
        FluentDataBuilder dataBuilder = given();
        for (Integer i = 0; i < 10; i++) {
            String name = 'Test ' + i;
            dataBuilder.andGivenAn(AccountTestRecord.build().named(name));
        }
        dataBuilder.inTheDatabase();

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
    static void usingOffsetThrowsAnExceptionIfTheOffsetDoesNotEvaluateToAnInteger() {
        String expr = 'QUERY(Account(offset: "1") [Id, Name])';
        runAndAssertRuntimeException(expr);
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
        givenAn(AccountTestRecord.build().named('Test').withNumberOfEmployees(5).withAnnualRevenue(1000))
            .inTheDatabase();

        String expr = 'QUERY(Account(where: Name = "Test" && NumberOfEmployees = 5 && AnnualRevenue = 1000) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void throwsAnExceptionWhenTheLeftSideOfAndAmpOperationIsNotACondition() {
        String expr = 'QUERY(Account(where: 1 && Id = "123"))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void throwsAnExceptionWhenTheRightSideOfAndAmpOperationIsNotACondition() {
        String expr = 'QUERY(Account(where: Id = "123" && 1))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void supportsMultipleAndConditionsThroughAndFunction() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: AND(Name = "Test", Id = "' + someAccount.Id + '")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void supportsEmbeddedAndFunctions() {
        Account someAccount = new Account(Name = 'Test', NumberOfEmployees = 5, AnnualRevenue = 1000);
        insert someAccount;

        String expr = 'QUERY(Account(where: AND(Name = "Test", AND(NumberOfEmployees = 5, AnnualRevenue = 1000))) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void usingTheAndFunctionThrowsAnExceptionWhenAnyArgumentDoesNotEvaluateToACondition() {
        String expr = 'QUERY(Account(where: AND(1, Id = "123")))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void anExceptionIsThrownWhenUsingAnUnsupportedFunctionWithinAQuery() {
        String expr = 'QUERY(Account(where: NOT(Name = "Test")))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void supportsOrConditionsThroughDoublePipeOperator() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: Name = "Test" || Id = "' + someAccount.Id + '") [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void throwsAnExceptionWhenTheLeftSideOfOrPipeOperationIsNotACondition() {
        String expr = 'QUERY(Account(where: 1 || Id = "123"))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void throwsAnExceptionWhenTheRightSideOfOrPipeOperationIsNotACondition() {
        String expr = 'QUERY(Account(where: Id = "123" || 1))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void supportsMultipleOrConditionsThroughDoublePipeOperator() {
        Account account1 = new Account(Name = 'Test 1');
        Account account2 = new Account(Name = 'Test 2');
        insert new List<Account>{
            account1, account2
        };

        String expr = 'QUERY(Account(where: Name = "Test 1" || Name = "Test 2" || Name = "Test 3"))';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Set<Id> resultIds = new Map<Id, SObject>(result).keySet();
        Assert.isTrue(resultIds.contains(account1.Id));
        Assert.isTrue(resultIds.contains(account2.Id));
    }

    @IsTest
    static void supportsOrConditionsThroughTheOrFunction() {
        Account someAccount = new Account(Name = 'Test');
        insert someAccount;

        String expr = 'QUERY(Account(where: OR(Name = "Test", Id = "' + someAccount.Id + '")) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void throwsAnExceptionWhenOneOfTheArgumentsToOrIsNotACondition() {
        String expr = 'QUERY(Account(where: OR(1, Id = "123")))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void supportsMixAndMatchingAndsAndOrs() {
        Account account1 = new Account(Name = 'Test 1');
        Account account2 = new Account(Name = 'Test 2');
        Account account3 = new Account(Name = 'Test 3', NumberOfEmployees = 5);
        Account account4 = new Account(Name = 'Test 4');
        insert new List<Account>{
            account1, account2, account3, account4
        };

        String expr = 'QUERY(Account(where: Name = "Test 1" || (Name = "Test 3" && NumberOfEmployees = 5) || Name = "Test 4"))';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(3, result.size());
        Set<Id> resultIds = new Map<Id, SObject>(result).keySet();
        Assert.isTrue(resultIds.contains(account1.Id));
        Assert.isTrue(resultIds.contains(account3.Id));
        Assert.isTrue(resultIds.contains(account4.Id));
    }

    @IsTest
    static void canMixAndMatchAndsAndOrsThroughFunctions() {
        Account account1 = new Account(Name = 'Test 1');
        Account account2 = new Account(Name = 'Test 2');
        Account account3 = new Account(Name = 'Test 3');
        Account account4 = new Account(Name = 'Test 4');
        insert new List<Account>{
            account1, account2, account3, account4
        };

        String expr = 'QUERY(\n' +
            '    Account(\n' +
            '        where: \n' +
            '            OR(\n' +
            '                Name = "Test 1", \n' +
            '                AND(Name = "Test 2", \n' +
            '                    Name = "Test 3"),\n' +
            '                Name = "Test 4"\n' +
            '                )\n' +
            '    )\n' +
            ')';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(2, result.size());
        Set<Id> resultIds = new Map<Id, SObject>(result).keySet();
        Assert.isTrue(resultIds.contains(account1.Id));
        Assert.isTrue(resultIds.contains(account4.Id));
    }

    @IsTest
    static void doesNotSupportLogicalOperationsOutsideOfWhere() {
        String expr = 'Query(Account(offset: 1 || 1))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void doesNotSupportBinaryOperationsOutsideOfWhere() {
        String expr = 'Query(Account(offset: 1 + 1))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void doesNotSupportNonOverloadedOperatorsWithinAWhereClause() {
        String expr = 'Query(Account(where: 1 + 1))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void doesNotSupportTheNegationOperatorWithinAQueryContext() {
        String expr = 'Query(Account(where: !Name = "Test"))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void supportsTheNegativeOperatorWithinAWhereClause() {
        Account someAccount = new Account(Name = 'Test', AnnualRevenue = -1000);
        insert someAccount;

        String expr = 'QUERY(Account(where: AnnualRevenue = -1000) [Id, Name])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(someAccount.Id, result[0].Id);
    }

    @IsTest
    static void cannotUseAnyFunctionOutsideOfWhere() {
        String expr = 'QUERY(Account(where: Name = "Test", offset: SIZE([1])))';
        runAndAssertRuntimeException(expr);
    }

    @IsTest
    static void allowsForSubqueries() {
        givenAn(AccountTestRecord.any().withAChildContact()).inTheDatabase();

        String expr = 'QUERY(Account[Id, Query(Contacts)])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result[0].Contacts.size());
    }

    @IsTest
    static void allowsForSubqueriesWithLimits() {
        givenAn(AccountTestRecord.any().withChildContacts(2)).inTheDatabase();

        String expr = 'QUERY(Account[Id, Query(Contacts(limit: 1))])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result[0].Contacts.size());
    }

    @IsTest
    static void allowsForSubqueriesWithWhereClauses() {
        givenAn(AccountTestRecord.any()
            .withAChildContact(ContactTestRecord.build().withLastName('Test 1'))
            .withAChildContact(ContactTestRecord.build().withLastName('Test 2'))
        )
            .inTheDatabase();

        String expr = 'QUERY(Account[Id, Query(Contacts(where: LastName = "Test 1"))])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result[0].Contacts.size());
    }

    @IsTest
    static void allowsForSubqueriesWithQueriedFields() {
        givenAn(AccountTestRecord.any().withAChildContact()).inTheDatabase();

        String expr = 'QUERY(Account[Id, Query(Contacts[Id, LastName])])';
        List<Account> result = (List<Account>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual(1, result[0].Contacts.size());
        Assert.isNotNull(result[0].Contacts[0].Id);
        Assert.isNotNull(result[0].Contacts[0].LastName);
    }

    @IsTest
    static void canQueryUsingADateTimeFunction() {
        givenAn(
            EventTestRecord.build().withAStartTimeOf(Date.newInstance(2021, 1, 1)))
            .inTheDatabase();

        String expr = 'QUERY(Event(where: StartDateTime > DATETIMEVALUE("2020-01-01 00:00:00")) [Id, StartDateTime])';
        List<Event> result = (List<Event>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void canQueryUsingTheNowFunction() {
        givenAn(
            EventTestRecord.build().withAStartTimeOf(Date.newInstance(2021, 1, 1)))
            .inTheDatabase();

        String expr = 'QUERY(Event(where: StartDateTime < NOW()) [Id, StartDateTime])';
        List<Event> result = (List<Event>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void canQueryUsingADateFunction_date() {
        givenAn(
            ContactTestRecord.build().bornOn(Date.newInstance(2021, 1, 1))
        ).inTheDatabase();

        String expr = 'QUERY(Contact(where: Birthdate > DATE(2020, 1, 1)) [Id, Birthdate])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void canQueryUsingADateFunction_dateValue() {
        givenAn(
            ContactTestRecord.build().bornOn(Date.newInstance(2021, 1, 1))
        ).inTheDatabase();

        String expr = 'QUERY(Contact(where: Birthdate > DATEVALUE("2020-01-01")) [Id, Birthdate])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void canQueryUsingTheTodayFunction() {
        givenAn(
            ContactTestRecord.build().bornOn(Date.newInstance(2021, 1, 1))
        ).inTheDatabase();

        String expr = 'QUERY(Contact(where: Birthdate < TODAY()) [Id, Birthdate])';
        List<Contact> result = (List<Contact>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void canCombineQueriesWithLetToUseCustomVariables() {
        givenAn(AccountTestRecord.build().named('Account 1').withAnnualRevenue(1000))
            .andGivenAn(AccountTestRecord.build().named('Account 2').withAnnualRevenue(2000))
            .andGivenAn(AccountTestRecord.build().named('Account 3').withAnnualRevenue(3000))
            .inTheDatabase();

        String expr = 'LET(\n' +
            '    {\n' +
            '        "$averageAnnualRevenue": Query(Account[AnnualRevenue]) -> MAP(AnnualRevenue) -> AVERAGE()\n' +
            '    },\n' +
            '    Query(Account(where: AnnualRevenue > $averageAnnualRevenue)[Name]) -> MAP(Name)\n' +
            ')';
        List<Object> result = (List<Object>) Evaluator.run(expr);

        Assert.areEqual(1, result.size());
        Assert.areEqual('Account 3', result[0]);
    }
}
