@IsTest
private class ContextGlobalVariableTest {
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
    private static void canGetFieldsFromTheRecordContext() {
        String expression = '@Context.Name';
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        Object result = Evaluator.run(expression, testRecord.Id);

        Assert.areEqual('Test', result);
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