@IsTest
private class GlobalContextTest {
    @IsTest
    private static void canUseARecordIdAsContext() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Object result = Evaluator.run('Name', accountRecord.Id);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void canUseARecordIdAsContext_runningWithoutSharing() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Object result = Evaluator.run('Name', accountRecord.Id, new Configuration().respectSharing(false));

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void usingARecordIdAsTheContextConsumesAQuery() {
        Account accountRecord = new Account(Name = 'Test');
        insert accountRecord;

        Integer queriesConsumedBefore = Limits.getQueries();
        Evaluator.run('Name', accountRecord.Id);
        Integer queriesConsumedAfter = Limits.getQueries();

        Assert.areEqual(1, queriesConsumedAfter - queriesConsumedBefore);
    }

    @IsTest
    private static void canReferenceAMergeField() {
        Account account = new Account(Name = 'Test');
        Assert.areEqual('Test', Evaluator.run('Name', account));
    }

    @IsTest
    private static void doesNotConsumeAQueryWhenThereAreNoMergeFieldsInTheFormula() {
        Integer queriesConsumedBefore = Limits.getQueries();
        Evaluator.run('1 + 1', IdGenerator.generate(Account.SObjectType));
        Integer queriesConsumedAfter = Limits.getQueries();

        Assert.areEqual(0, queriesConsumedAfter - queriesConsumedBefore);
    }

    @IsTest
    private static void canUseARecordIdAsContextToGetAggregateInformationFromChildren() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Object revenueByEmployee = Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
            parentAccount.Id);

        Assert.areEqual(10, revenueByEmployee);
    }

    @IsTest
    private static void canUseARecordIdAsContextToGetAggregateInformationFromChildren_withNullValues() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = null);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Decimal revenueByEmployee = (Decimal) Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
            parentAccount.Id);
        revenueByEmployee = revenueByEmployee.setScale(2);

        Assert.areEqual(13.33, revenueByEmployee);
    }

    @IsTest
    private static void theRecordIdIsAccessibleAsAContextVariable_resolvingFromId() {
        String expression = '@Id';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual(testRecord.Id, result);
    }

    @IsTest
    private static void theRecordIdIsAccessibleAsAContextVariable_resolvingFromFullRecord() {
        String expression = '@Id';
        Id recordId = IdGenerator.generate(Account.SObjectType);
        Account testRecord = new Account(
            Id = recordId,
            Name = 'Test'
        );

        Object result = Evaluator.run(expression, testRecord);

        Assert.areEqual(recordId, result);
    }

    @IsTest
    private static void throwsARuntimeExceptionWhenReferencingAGlobalVariableThatDoesNotExist() {
        String expression = '@DoesNotExist';
        Id recordId = IdGenerator.generate(Account.SObjectType);
        Account testRecord = new Account(
            Id = recordId,
            Name = 'Test'
        );

        try {
            Evaluator.run(expression, testRecord);
            System.assert(false, 'Expected a runtime exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canPassCustomContext() {
        String expression = '@MyCustomContext';
        Map<String, Object> customContext = new Map<String, Object>{
            'MyCustomContext' => 'MyCustomContextValue'
        };

        Object result = Evaluator.run(expression, new Configuration().withCustomContext(customContext));

        Assert.areEqual('MyCustomContextValue', result);
    }


    // TODO: Can pass anything as a customn context
    // TODO: Run time exception when trying to access a field that doesn't exist
}
