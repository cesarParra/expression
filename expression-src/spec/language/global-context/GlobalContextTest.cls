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

    // TODO: The endpoint with custom record context can also receive a config.
    // TODO: Endpoint can received a prequeried SObject on top of the ID. If all of the fields have
    // already been queried, then no need to query again.
    // TODO: Many record contexts for different SObject types -> expect one query per type
    // TODO: Many record contexts for the same SObject type -> expect to be bulk
    // TODO: Validate that the config cannot receive mroe than one custom record context with the same name
}
