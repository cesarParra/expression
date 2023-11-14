@IsTest
private class EvaluatorTest {
    @IsTest
    private static void canReferenceAMergeField() {
        Account account = new Account(Name = 'Test');
        Assert.areEqual('Test', Evaluator.run('Name', account));
    }

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
    private static void dotNotationGetsRelatedData() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Name FROM Contact WHERE Id = :childContact.Id];

        Evaluator.run('Account.Name', queriedContact);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevels() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Contact queriedContact = [SELECT Id, LastName, Account.Parent.Parent.Name FROM Contact WHERE Id = :childContact.Id];

        Object result = Evaluator.run('Account.Parent.Parent.Name', queriedContact);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void dotNotationThroughMultipleLevelsUsingId() {
        Account greatGrandParent = new Account(Name = 'GreatGrandParent');
        insert greatGrandParent;

        Account grandParentAccount = new Account(Name = 'GrandParent', ParentId = greatGrandParent.Id);
        insert grandParentAccount;

        Account parentAccount = new Account(Name = 'Parent', ParentId = grandParentAccount.Id);
        insert parentAccount;

        Contact childContact = new Contact(LastName = 'Child', AccountId = parentAccount.Id);
        insert childContact;

        Object result = Evaluator.run('Account.Parent.Parent.Name', childContact.Id);

        Assert.areEqual('GreatGrandParent', result);
    }

    @IsTest
    private static void canBuildListLiterals() {
        Assert.areEqual(3, Evaluator.run('SIZE([1, 2, 3])'));
    }

    @IsTest
    private static void spreadOperatorExpandsAList() {
        Assert.areEqual(3, Evaluator.run('SIZE([...LIST(1, 2, 3)])'));
    }

    @IsTest
    private static void spreadOperatorCanBeUsedInsideOfAListFunction() {
        Assert.areEqual(3, Evaluator.run('SIZE(LIST(...LIST(1, 2, 3)))'));
        Assert.areEqual(6, Evaluator.run('SIZE(LIST(1, 2, 3, ...[4, 5, 6]))'));
    }

    @IsTest
    private static void mapLiteralCreatesAMap() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{"a": 1, "b": 2}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    private static void mapsSupportTheSpreadOperator() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{...{"a": 1, "b": 2}}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(2, result.get('b'));
    }

    @IsTest
    private static void spreadOperatorInMapRespectTheRightmostValue() {
        Map<Object, Object> result = (Map<Object, Object>) Evaluator.run('{...{"a": 1, "b": 2}, "b": 3}');
        Assert.areEqual(1, result.get('a'));
        Assert.areEqual(3, result.get('b'));
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_recordAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Account parentAccountWithChildren = [SELECT Id, Name, (SELECT Id, NumberOfEmployees, Parent.Name FROM ChildAccounts) FROM Account WHERE Id = :parentAccount.Id];

        List<Object> result = (List<Object>) Evaluator.run('MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})', parentAccountWithChildren);

        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>) result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>) result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void canExtractDataDirectlyFromChildren() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        Object result = Evaluator.run('SIZE(ChildAccounts)', parentAccount.Id);

        Assert.areEqual(2, result);
    }

    @IsTest
    private static void shouldBeAbleToAccessDataFromParentWhenMappingAChildRelationshipList_idAsContext() {
        Account parentAccount = new Account(Name = 'Parent');
        insert parentAccount;

        Account childAccount1 = new Account(Name = 'Child1', ParentId = parentAccount.Id, NumberOfEmployees = 10, AnnualRevenue = 100);
        Account childAccount2 = new Account(Name = 'Child2', ParentId = parentAccount.Id, NumberOfEmployees = 20, AnnualRevenue = 200);
        insert new List<SObject>{
            childAccount1, childAccount2
        };

        List<Object> result = (List<Object>) Evaluator.run(
            'MAP(ChildAccounts, {"parentName": Parent.Name, "numberOfEmployees": NumberOfEmployees})',
            parentAccount.Id
        );

        Assert.areEqual('Parent', ((Map<Object, Object>) result[0]).get('parentName'));
        Assert.areEqual(10, ((Map<Object, Object>) result[0]).get('numberOfEmployees'));
        Assert.areEqual('Parent', ((Map<Object, Object>) result[1]).get('parentName'));
        Assert.areEqual(20, ((Map<Object, Object>) result[1]).get('numberOfEmployees'));
    }

    @IsTest
    private static void theIdIsNotReferencedTwiceInTheQueryWhenReferenced() {
        Account parentAccount = new Account(Name = 'ACME');
        insert parentAccount;

        Account childAccount = new Account(Name = 'ACME Child', ParentId = parentAccount.Id);
        insert childAccount;

        Object result = Evaluator.run('map(ChildAccounts, Id)', parentAccount.Id);

        Assert.areEqual(childAccount.Id, ((List<Object>) result)[0]);
    }

    @IsTest
    private static void canPipeFunctionCalls() {
        Assert.areEqual(3, Evaluator.run('LIST(1, 2, 3) -> SIZE()'));
    }

    @IsTest
    private static void canPipeFunctionCalls_pipeHasPrecedenceWhenPairedWithOtherExpressions() {
        Assert.areEqual(8, Evaluator.run('LIST(1, 2, 3) -> SIZE() + 5'));
    }

    @IsTest
    private static void canPipeFunctionCallsMultipleTimes() {
        Object result = Evaluator.run('[1, 2, 3, 4, 5, 6] -> WHERE($current > 2) -> WHERE($current < 5)');
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual(3, ((List<Object>) result)[0]);
        Assert.areEqual(4, ((List<Object>) result)[1]);
    }

    @IsTest
    private static void canUseCustomFunctions() {
        CustomFunctionRepository mockRepository = new MockFunctionRepository();
        CustomFunctionRepository.mockInstance = mockRepository;

        // This custom function concatenates the arguments.
        Object result = Evaluator.run('CUSTOMFUNCION("TestFormula", 1, 2)');
        Assert.areEqual('TestFormula12', result);
    }

    private class MockFunctionRepository extends CustomFunctionRepository {
        public override IExpressionFunction getByName(String functionName) {
            return new MockFunction();
        }
    }

    private class MockFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            String concatenated = '';
            for (Object arg : args) {
                concatenated += String.valueOf(arg);
            }
            return concatenated;
        }
    }

    @IsTest
    private static void canEvaluateCustomLabels() {
        LabelWrapper.mockLabel = new DummyLabel();
        String formula = '$Label.c.MyLabelName';
        Assert.areEqual('Value', Evaluator.run(formula));
    }

    private class DummyLabel implements LabelWrapper.ILabel {
        public String get(String namespace, String label, String language) {
            return 'Value';
        }
    }

    @IsTest
    private static void canAccessMapKeysUsingDotNotation() {
        String formula = 'MAP([{"keyName": "A"}, {"keyName": "B"}], $current.keyName)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(2, ((List<Object>) result).size());
        Assert.areEqual('A', ((List<Object>) result)[0]);
        Assert.areEqual('B', ((List<Object>) result)[1]);
    }

    @IsTest
    private static void transformFunctionCanConvertFromOneObjectToAnyOther() {
        String formula = 'TRANSFORM("a", UPPER($source))';
        Object result = Evaluator.run(formula);
        Assert.areEqual('A', result);
    }

    @IsTest
    private static void letFunctionAllowsForVariablesToBeDefined() {
        String formula = 'LET({"$a": 1, "$b": 2},  $a + $b)';
        Object result = Evaluator.run(formula);
        Assert.areEqual(3, result);
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToSObjectGetExpr() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('FETCH("Account", []) -> FIRST().Name("Test")',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenPassingArgumentToMapGetExpr() {
        try {
            Evaluator.run('{"Name": "Test"}.Name("Test")');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingFieldThatDoesNotExist() {
        Account testRecord = new Account(Name = 'Test');
        insert testRecord;

        try {
            Evaluator.run('FETCH("Account", []) -> FIRST().NonExistentField',
                testRecord.Id);
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenGettingKeyThatDoesNotExist() {
        try {
            Evaluator.run('{"Name": "Test"}.NonExistentKey');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenBubblingErrorsFromGlobalVariableResolvers() {
        try {
            Evaluator.run('$Action.Apex.NonExistentClass');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void throwsRuntimeExceptionWhenUsingGetExpressionInAnInvalidWay() {
        try {
            Evaluator.run('$DoesNotExist.DoSomething');
            Assert.fail('Expected RuntimeException');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void commentsAreIgnored() {
        Assert.areEqual(1, Evaluator.run('1 # comment'));
    }

    @IsTest
    private static void canReferenceCustomMetadataTypeRecords() {
        String formula = '$CustomMetadata.MyCustomMetadataType__mdt.MyRecord.MyField__c';
        try {
            Evaluator.run(formula);

            // Expecting an exception since the only way to test against a CMT
            // is having a record of that type in the org.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canReferenceStaticResources() {
        String formula = '$Resource.MyStaticResource';
        try {
            Evaluator.run(formula);

            // Expecting an exception since that static resource
            // doesn't exist.
            // This test is essentially for coverage.
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.RuntimeException.class);
        }
    }

    @IsTest
    private static void canInvokeCustomFunctions() {
        QRunner.mockRunner = new FakeExpressionFunctionRunner();
        String formula = 'CUSTOMFUNCTION()';
        Object result = Evaluator.run(formula);
        Assert.areEqual('Test', result);
    }

    private class FakeExpressionFunctionRunner extends QRunner {
        public override List<SObject> run(Q query) {
            return new List<Expression_Function__mdt>{
                new Expression_Function__mdt(
                    Apex_Class__c = EvaluatorTest.FakeFunction.class.getName()
                )
            };
        }
    }

    public class FakeFunction implements IExpressionFunction {
        public Object execute(List<Object> args) {
            return 'Test';
        }
    }

    @IsTest
    private static void throwsExceptionIfThereAreMoreTokensAfterTheEndOfACompleteExpression() {
        try {
            Evaluator.run('1 + 1 1');
            Assert.fail('Expected exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, Exceptions.ParsingException.class);
        }
    }

    // TODO: The record Id is accessible as a context variable
    // TODO: The record itself is accessible as a context variable
    // TODO: Can pass anything as a customn context
}
