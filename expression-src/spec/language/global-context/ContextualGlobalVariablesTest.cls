@IsTest
private class ContextualGlobalVariablesTest {
    @IsTest
    private static void theIdIsAccessibleAsAContextVariable_singleId() {
        String expression = '@Id';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual(testRecord.Id, result);
    }

    @IsTest
    private static void theIdsAreAccessibleAsAContextVariable_multipleIds() {
        String expression = '@Ids';
        Account testRecord1 = new Account(Name = 'Test1');
        Account testRecord2 = new Account(Name = 'Test2');
        insert new List<SObject>{
            testRecord1, testRecord2
        };

        Object result = Evaluator.run(expression, new Set<Id>{
            testRecord1.Id, testRecord2.Id
        });

        Assert.isNotNull(result);
        Set<Id> ids = (Set<Id>) result;
        Assert.areEqual(2, ids.size());
        Assert.isTrue(ids.contains(testRecord1.Id));
        Assert.isTrue(ids.contains(testRecord2.Id));
    }

    @IsTest
    private static void theRecordContextIsAccessibleAsAContextVariable_resolvingFromId() {
        String expression = '@Context';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.isNotNull(result);
        SObject record = (SObject) result;
        Assert.areEqual(testRecord.Id, record.Id);
    }

    @IsTest
    private static void theContextRecordsAreAccessibleAsContextVariable_multipleIdsAsContext() {
        String expression = '@Context';
        Account testRecord1 = new Account(Name = 'Test1');
        Account testRecord2 = new Account(Name = 'Test2');
        insert new List<SObject>{
            testRecord1, testRecord2
        };

        Object result = Evaluator.run(expression, new Set<Id>{
            testRecord1.Id, testRecord2.Id
        });

        Assert.isNotNull(result);
        List<SObject> records = (List<SObject>) result;
        Assert.areEqual(2, records.size());
        Assert.areEqual(testRecord1.Id, records[0].Id);
        Assert.areEqual(testRecord2.Id, records[1].Id);
    }

    @IsTest
    private static void canGetFieldsFromTheRecordContext() {
        String expression = '@Context.Name';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual('Test', result);
    }

    @IsTest
    private static void canResolveMultipleContextEventWhenThereIsOnlyOneId() {
        List<Account> records = new List<Account>{
            new Account(Name = 'Example 1')
        };
        insert records;

        Object result = Evaluator.run(
            'MAP(@context, {Id : Name == "Example 1"})',
            new Set<Id>{
                records[0].Id
            }
        );

        Assert.isNotNull(result);
        List<Object> mappedRecords = (List<Object>) result;
        Assert.areEqual(1, mappedRecords.size());

        Map<Object, Object> mappedRecord = (Map<Object, Object>) mappedRecords[0];
        Assert.areEqual(true, mappedRecord.get(records[0].Id));
    }

    @IsTest
    private static void canGetFieldsFromTheRecordContextWhenDealingWithAList() {
        String expression = 'MAP(@Context, Name)';
        Account testRecord1 = new Account(Name = 'Test1');
        Account testRecord2 = new Account(Name = 'Test2');
        insert new List<SObject>{
            testRecord1, testRecord2
        };

        List<Object> result = (List<Object>) Evaluator.run(expression, new Set<Id>{
            testRecord1.Id, testRecord2.Id
        });

        Assert.areEqual('Test1', result[0]);
        Assert.areEqual('Test2', result[1]);
    }

    @IsTest
    private static void canAccessContextFromInsideOfACollectionFunctionThatResolvesQueries() {
        Account parent = new Account(Name = 'Parent');
        insert parent;
        Account child = new Account(Name = 'Child1', ParentId = parent.Id);
        insert child;

        String expression = 'MAP(\n' +
            '    ChildAccounts, \n' +
            '    {\n' +
            '        "name": Name, \n' +
            '        "parentName": @Context.Name, \n' +
            '        "fullParent": @Context\n' +
            '    }\n' +
            ')';

        Object result = Evaluator.run(expression, parent.Id);

        Assert.isNotNull(result);
        List<Object> mappedRecords = (List<Object>) result;
        Assert.areEqual(1, mappedRecords.size());

        Map<Object, Object> mappedRecord = (Map<Object, Object>) mappedRecords[0];
        Assert.areEqual('Child1', mappedRecord.get('name'));
        Assert.areEqual('Parent', mappedRecord.get('parentName'));

        SObject parentRecord = (SObject) mappedRecord.get('fullParent');
        Assert.areEqual(parent.Id, parentRecord.Id);
        Assert.areEqual(parent.Name, parentRecord.get('Name'));
    }

    @IsTest
    private static void canAccessParentObjects() {
        String expression = '@Context.Parent';
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;
        Account testRecord = new Account(Name = 'Test', ParentId = parentAccount.Id);
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual(parentAccount.Id, ((SObject) result).Id);
    }

    @IsTest
    private static void canAccessParentObjects_whenThereIsNoParent() {
        String expression = '@Context.Parent';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.isNull(result);
    }

    @IsTest
    private static void canGetFieldsFromTheRecordContext_2levels() {
        String expression = '@Context.Parent.Name';
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;
        Account testRecord = new Account(Name = 'Test', ParentId = parentAccount.Id);
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual('Parent', result);
    }

    @IsTest
    private static void theContextGetsCorrectlyQueriedFromAnInnerQuery() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        String expression = 'MAP(ChildAccounts, {"name": Name, "parent": @Context.Name})';

        List<Object> result = (List<Object>) Evaluator.run(expression, parentAccount.Id);

        Assert.areEqual('Child1', ((Map<Object, Object>) result[0]).get('name'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parent'));

        Assert.areEqual('Child2', ((Map<Object, Object>) result[1]).get('name'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parent'));
    }

    @IsTest
    private static void theContextGetsCorrectlyQueriedFromAnInnerQuery_grandParentReferenceThroughContext() {
        Account grandParentAccount = new Account(Name = 'GrandParent');
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        String expression = 'MAP(ChildAccounts, {"name": Name, "parent": @Context.Name, "grandParent": @Context.Parent.Name})';

        List<Object> result = (List<Object>) Evaluator.run(expression, parentAccount.Id);

        Assert.areEqual('Child1', ((Map<Object, Object>) result[0]).get('name'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parent'));
        Assert.areEqual('GrandParent', ((Map<Object, Object>) result[0]).get('grandParent'));

        Assert.areEqual('Child2', ((Map<Object, Object>) result[1]).get('name'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parent'));
        Assert.areEqual('GrandParent', ((Map<Object, Object>) result[1]).get('grandParent'));
    }

    @IsTest
    private static void theRecordIsAccessibleAsAContextVariable_resolvingFromFullRecord() {
        String expression = '@Context';
        Account testRecord = new Account(
            Id = IdGenerator.generate(Account.SObjectType),
            Name = 'Test'
        );

        Object result = Evaluator.run(expression, testRecord);

        Assert.isNotNull(result);
        SObject record = (SObject) result;
        Assert.areEqual(testRecord.Id, record.Id);
        Assert.areEqual(testRecord.Name, record.get('Name'));
    }

    @IsTest
    private static void theRecordsAreAccessibleAsContextVariable_multipleRecordsAsContext() {
        String expression = '@Context';
        Account testRecord1 = new Account(
            Id = IdGenerator.generate(Account.SObjectType),
            Name = 'Test1'
        );
        Account testRecord2 = new Account(
            Id = IdGenerator.generate(Account.SObjectType),
            Name = 'Test2'
        );

        Object result = Evaluator.run(expression, new List<SObject>{
            testRecord1, testRecord2
        });

        Assert.isNotNull(result);
        List<SObject> records = (List<SObject>) result;
        Assert.areEqual(2, records.size());
        Assert.areEqual(testRecord1.Id, records[0].Id);
        Assert.areEqual(testRecord1.Name, records[0].get('Name'));
        Assert.areEqual(testRecord2.Id, records[1].Id);
        Assert.areEqual(testRecord2.Name, records[1].get('Name'));
    }

    @IsTest
    private static void canAccessAChildRecordsRelationshipThroughTheContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        String expr = '@Context.Contacts';

        Object result = Evaluator.run(expr, parentAccount.Id);

        Assert.isNotNull(result);
        List<SObject> contacts = (List<SObject>) result;
        Assert.areEqual(1, contacts.size());
    }
}
