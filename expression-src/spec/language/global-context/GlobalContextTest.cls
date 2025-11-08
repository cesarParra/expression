@IsTest
private class GlobalContextTest {
    @IsTest
    private static void canUseARecordIdAsContext() {
        Account accountRecord = new Account(Name = 'Test');
        QDB.getInstance().doInsert(accountRecord);

        Object result = Evaluator.run('Name', accountRecord.Id);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void canUseARecordIdAsContext_runningWithoutSharing() {
        Account accountRecord = new Account(Name = 'Test');
        QDB.getInstance().doInsert(accountRecord);

        Object result = Evaluator.run('Name', accountRecord.Id, new Configuration().respectSharing(false));

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void usingARecordIdAsTheContextConsumesAQuery() {
        Account accountRecord = new Account(Name = 'Test');
        QDB.getInstance().doInsert(accountRecord);

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
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        QDB.getInstance().doInsert(new List<SObject> {
            childAccount1, childAccount2
        });

        Object revenueByEmployee = Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
            parentAccount.Id);

        Assert.areEqual(10, revenueByEmployee);
    }

    @IsTest
    private static void canUseARecordIdAsContextToGetAggregateInformationFromChildren_withNullValues() {
        Account parentAccount = new Account(Name = 'Parent');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = null);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        QDB.getInstance().doInsert(new List<SObject> {
            childAccount1, childAccount2
        });

        Decimal revenueByEmployee = (Decimal)Evaluator.run('AVERAGE(MAP(ChildAccounts, AnnualRevenue)) / AVERAGE(MAP(ChildAccounts, NumberOfEmployees))',
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
        Map<String, Object> customContext = new Map<String, Object> {
            'MyCustomContext' => 'MyCustomContextValue'
        };

        Object result = Evaluator.run(expression, new Configuration().withCustomContext(customContext));

        Assert.areEqual('MyCustomContextValue', result);
    }

    @IsTest
    private static void canPassCustomContextWithNestedValues() {
        String expression = '@MyCustomContext.MyNestedValue';
        Map<String, Object> customContext = new Map<String, Object> {
            'MyCustomContext' => new Map<String, Object> {
                'MyNestedValue' => 'MyNestedValueValue'
            }
        };

        Object result = Evaluator.run(expression, new Configuration().withCustomContext(customContext));

        Assert.areEqual('MyNestedValueValue', result);
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_recordAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject> {
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees, Parent.Name FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        List<Object> result = (List<Object>)Evaluator.run('MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})', parentAccountWithChildren);

        Assert.areEqual('Parent', ((Map<Object, Object>)result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>)result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>)result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>)result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void canExtractDataDirectlyFromChildren() {
        Account parentAccount = new Account(Name = 'Parent');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        QDB.getInstance().doInsert(new List<SObject> {
            childAccount1, childAccount2
        });

        Object result = Evaluator.run('SIZE(ChildAccounts)', parentAccount.Id);

        Assert.areEqual(2, result);
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_idAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        QDB.getInstance().doInsert(new List<SObject> {
            childAccount1, childAccount2
        });

        List<Object> result = (List<Object>)Evaluator.run(
            'MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})',
            parentAccount.Id
        );

        Assert.areEqual('Parent', ((Map<Object, Object>)result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>)result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>)result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>)result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void theIdIsNotReferencedTwiceInTheQueryWhenReferenced() {
        Account parentAccount = new Account(Name = 'ACME');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount = new Account(Name = 'ACME Child', ParentId = parentAccount.Id);
        QDB.getInstance().doInsert(childAccount);

        Object result = Evaluator.run('map(ChildAccounts, Id)', parentAccount.Id);

        Assert.areEqual(childAccount.Id, ((List<Object>)result)[0]);
    }

    @IsTest
    private static void canCreateCustomContextsBasedOnASpecifiedId() {
        Account accountRecord = new Account(Name = 'Acme');
        insert accountRecord;

        CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);

        String expressionFormula = '@TargetAccount.Name';
        Object result = Evaluator.run(expressionFormula, customRecordContext, new Configuration());

        Assert.areEqual('Acme', result);
        Assert.areEqual(1, Limits.getQueries(), 'Expect one query to retrieve the TargetAccount record');
    }

    @IsTest
    private static void canChangeTheCustomContextPrefix() {
        Account accountRecord = new Account(Name = 'Acme');
        insert accountRecord;

        Configuration config = new Configuration()
            .withGlobalContextVariablePrefix('$');

        CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);

        String expressionFormula = '$TargetAccount.Name';
        Object result = Evaluator.run(expressionFormula, customRecordContext, config);

        Assert.areEqual('Acme', result);
    }

    @IsTest
    private static void canCreateCustomContextsBasedOnASpecifiedIdInBulk_differentSObjectTypes() {
        Account accountRecord = new Account(Name = 'Acme', NumberOfEmployees = 50);
        insert accountRecord;

        Contact contactRecord = new Contact(FirstName = 'John', LastName = 'Doe');
        insert contactRecord;

        CustomRecordContext accountRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id);
        CustomRecordContext contactRecordContext = new CustomRecordContext('TargetContact', contactRecord.Id);

        String expressionFormula = '@TargetContact.LastName + TEXT(@TargetAccount.NumberOfEmployees)';
        Object result = Evaluator.run(expressionFormula,
            new List<CustomRecordContext> { accountRecordContext, contactRecordContext }, new Configuration());

        Assert.areEqual('Doe50', result);
        Assert.areEqual(2, Limits.getQueries(), 'Expect one query per SObject type');
    }

    @IsTest
    private static void canCreateCustomContextsBasedOnASpecifiedIdInBulk_sameSObjectTypes() {
        Account accountRecord1 = new Account(Name = 'Acme', NumberOfEmployees = 50);
        insert accountRecord1;

        Account accountRecord2 = new Account(Name = 'Beta', NumberOfEmployees = 100);
        insert accountRecord2;

        CustomRecordContext accountRecordContext = new CustomRecordContext('FirstAccount', accountRecord1.Id);
        CustomRecordContext contactRecordContext = new CustomRecordContext('SecondAccount', accountRecord2.Id);

        String expressionFormula = '@FirstAccount.NumberOfEmployees + @SecondAccount.NumberOfEmployees';
        Object result = Evaluator.run(expressionFormula,
            new List<CustomRecordContext> { accountRecordContext, contactRecordContext }, new Configuration());

        Assert.areEqual(150, result);
        Assert.areEqual(1, Limits.getQueries(), 'Expect one query per SObject type');
    }

    @IsTest
    private static void customContextsDoNotQueryWhenSObjectIsProvidedWithAllReferencedFields() {
        Account accountRecord = new Account(Name = 'Acme');
        insert accountRecord;

        CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id, accountRecord);

        String expressionFormula = '@TargetAccount.Name';
        Object result = Evaluator.run(expressionFormula, customRecordContext, new Configuration());

        Assert.areEqual('Acme', result);
        Assert.areEqual(0, Limits.getQueries(), 'No queries should be consumed');
    }

    @IsTest
    private static void customContextsDoNotQueryWhenSObjectIsProvidedWithAllReferencedFields_whenFieldValueIsEmpty() {
        Account accountRecord = new Account(Name = 'Acme');
        insert accountRecord;

        Account queriedAccount = [SELECT Id, Name, NumberOfEmployees FROM Account WHERE Id = :accountRecord.Id];

        CustomRecordContext customRecordContext = new CustomRecordContext('TargetAccount', accountRecord.Id, queriedAccount);

        // NumberOfEmployees is null, but it should not trigger a query since the field was explicitly queried.
        String expressionFormula = '@TargetAccount.NumberOfEmployees';
        Integer queriesBeforeEvaluation = Limits.getQueries();
        Object result = Evaluator.run(expressionFormula, customRecordContext, new Configuration());
        Integer queriesAfterEvaluation = Limits.getQueries();

        Integer queriesConsumed = queriesAfterEvaluation - queriesBeforeEvaluation;

        Assert.areEqual(null, result);
        Assert.areEqual(0, queriesConsumed, 'No queries should be consumed');
    }

    @IsTest
    private static void canResolveMultipleExpressionsAtTheSameTime() {
        Account accountRecord1 = new Account(Name = 'Acme', NumberOfEmployees = 100);
        insert accountRecord1;

        Account accountRecord2 = new Account(Name = 'Salesforce', NumberOfEmployees = 200);
        insert accountRecord2;

        CustomRecordContext customRecordContext1 = new CustomRecordContext('TargetAccount', accountRecord1.Id);
        CustomRecordContext customRecordContext2 = new CustomRecordContext('SourceAccount', accountRecord2.Id);

        String expression1 = '@TargetAccount.Name + " & " + @SourceAccount.Name';
        String expression2 = '@TargetAccount.NumberOfEmployees + @SourceAccount.NumberOfEmployees';
        List<Result> results = Evaluator.run(new List<String> { expression1, expression2 },
            new List<CustomRecordContext> { customRecordContext1, customRecordContext2 },
            new Configuration()
        );

        Assert.areEqual(2, results.size(), 'Expect two results, one per expression');
        Assert.areEqual('Acme & Salesforce', results[0].getValue());
        Assert.areEqual(300, results[1].getValue());
        Assert.areEqual(1, Limits.getQueries(), 'Expected a single query per SObject type (only Account)');
    }
}
